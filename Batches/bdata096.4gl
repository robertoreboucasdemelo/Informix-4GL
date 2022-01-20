#==============================================================================#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema       : Central 24h                                                  #
# Modulo        : bdata096                                                     #
# Analista Resp : Ligia Mattge                                                 #
# OSF           : Extrai os acionamentos do dia por motivo/quantidade e gera   #
#                 um arquivo com os servicos.                                  #
# .............................................................................#
# Desenvolvimento : Ligia Mattge                                               #
# Liberacao       : 08/02/2007                                                 #
#..............................................................................#
#                                                                              #
#                   * * * Alteracoes * * *                                     #
#                                                                              #
# Data       Autor Fabrica     Origem     Alteracao                            #
# ---------- ----------------- ---------- -------------------------------------#
#..............................................................................#

globals  "/homedsa/projetos/geral/globals/glct.4gl"

   define m_dir       char(100)
         ,m_hora      datetime hour to second
         ,m_path1     char(300)
         ,m_path2     char(300)
         ,m_path_l    char(300)
         ,m_data      date

globals
   define g_ismqconn smallint
end globals

main
 
  let m_hora = current
  display "Inicio processamento bdata096 as ", m_hora

  let g_r1 = 0
  let g_r2 = 0
  let g_r3 = 0
  let g_r4 = 0
  let g_r5 = 0
  let g_r6 = 0
  let g_r7 = 0
  let g_r8 = 0
  let g_total = 0

  call fun_dba_abre_banco("CT24HS")

  set isolation to dirty read

  let m_hora = null  

  let m_data = arg_val(1)
  if m_data is null then
     let m_data = today - 1
  end if
  display "Data de Processamento ", m_data

  display "Busca_Path"
  call bdata096_busca_path()

  display "Cria Tabelas Temporarias"
  call bdata096_prepara()

  call bdata096_prepare()

  display "bdata096 - Processamento"
  call bdata096_processa()

  drop table bdata096_tmp
  
  call bdata096_email()
  
  let m_hora = current
  display "Termino processamento bdata096 as ", m_hora

end main

#-------------------------#
function bdata096_prepara()
#-------------------------#
define l_msg     char(400)

let l_msg = null
  
  whenever error continue

  create temp table bdata096_tmp
        (flag       smallint,
         motivo     char(40),
         servico    integer,
         ano        smallint) with no log

  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_msg = "Erro: ", sqlca.sqlcode, "/", sqlca.sqlerrd[2],
             " na criacao da tabela temporaria."
     display l_msg
     exit program(1) 
  end if

  whenever error continue
  create index idx_tmp on bdata096_tmp(motivo)
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_msg = "Erro: ", sqlca.sqlcode, "/", sqlca.sqlerrd[2],
             " na criacao do indice."
     display l_msg
     exit program(1) 
  end if
  
 
end function


#------------------------------#
 function bdata096_busca_path()
#------------------------------#
    # ---> INICIALIZACAO DAS VARIAVEIS
    let m_dir = null
    let m_path_l = null
    let m_path1 = null
    let m_path2 = null
    
    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE LOG
    let m_path_l = f_path("DAT","LOG")

    if m_path_l is null then
       let m_path_l = "."
    end if

    let m_path_l = m_path_l clipped, "/bdata096.log"
     
     display "Log: ", m_path_l
     
    call startlog(m_path_l)

    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO RELATORIO
    let m_dir = f_path("DAT","ARQUIVO")

    if m_dir is null then
        let m_dir = "."
    end if
    
    display "Arquivo: ", m_dir

    let m_path1 = m_dir clipped, "/ADAT096001.doc"
    let m_path2 = m_dir clipped, "/ADAT096002.xls"
    
    display "m_path1: ", m_path1
    display "m_path2: ", m_path2
    
    
 end function

#-------------------------#
function bdata096_prepare()
#-------------------------#

  define l_sql char(1000)

  let l_sql = " select etapa.funmat, ",
                     " servico.acnnaomtv, ",
                     " etapa.atdetpcod, ",
                     " servico.atdsrvorg, ",
                     " servico.atdsrvnum, ",
                     " servico.atdsrvano, ",
                     " servico.acnsttflg, ",
                     " servico.prslocflg, ",
                     " servico.asitipcod, ",
                     " servico.vclcoddig ",
                " from datmservico servico, ",
                     " datmsrvacp etapa ",
               " where etapa.atdsrvnum = servico.atdsrvnum ",
                 " and etapa.atdsrvano = servico.atdsrvano ",
                 " and etapa.atdsrvseq = ",
                   " (select max(atdsrvseq) ",
                      " from datmsrvacp datmsrvacp ",
                     " where datmsrvacp.atdsrvnum = servico.atdsrvnum ",
                       " and datmsrvacp.atdsrvano = servico.atdsrvano) ",
                       " and etapa.atdetpdat = ? ",
                       " and etapa.atdetpcod in (3,4,43) "

  prepare pbdata096001 from l_sql
  declare cbdata096001 cursor for pbdata096001

  let l_sql = " select motivo, count(*) ",
              "   from bdata096_tmp ",
              "  where flag = 1 ",
              "  group by 1 ",
              "  order by 2 desc "

  prepare pbdata096002 from l_sql
  declare cbdata096002 cursor for pbdata096002

  let l_sql = " select motivo,  count(*) ",
              "   from bdata096_tmp ",
              "  where flag = 2 ",
              "  group by 1 ",
              "  order by 2 desc "

  prepare pbdata096003 from l_sql
  declare cbdata096003 cursor for pbdata096003

  let l_sql = " select motivo, servico, ano ",
              " from bdata096_tmp ",
              " order by 1 "

  prepare pbdata096004 from l_sql
  declare cbdata096004 cursor for pbdata096004

  let l_sql = " insert into bdata096_tmp(flag, motivo,servico,ano) ",
              " values(?,?,?,?) "

  prepare pbdata096005 from l_sql

  let l_sql = " select count(*) ",
                " from bdata096_tmp ",
                " where flag = ? "

  prepare pbdata096006 from l_sql
  declare cbdata096006 cursor for pbdata096006

end function

#------------#
function bdata096_processa()
#------------#

  define l_funmat            like datmsrvacp.funmat
        ,l_acnnaomtv         like datmservico.acnnaomtv
        ,l_atdetpcod         like datmsrvacp.atdetpcod
        ,l_atdsrvorg         like datmservico.atdsrvorg
        ,l_atdsrvnum         like datmservico.atdsrvnum
        ,l_atdsrvano         like datmservico.atdsrvano
        ,l_acnsttflg         like datmservico.acnsttflg
        ,l_aciona            smallint
        ,l_cidnom            like datmlcl.cidnom
        ,l_ufdcod            like datmlcl.ufdcod
        ,l_dptsgl            char(6) ##like isskfunc.dptsgl,
        ,l_total_geral       integer
        ,l_lclltt            like datmlcl.lclltt
        ,l_lcllgt            like datmlcl.lcllgt
        ,l_total_auto        integer
        ,l_total_re          integer
        ,l_total_manual      integer
        ,l_total_manual_re   integer
        ,l_total_manual_auto integer
        ,l_motivo            char(40)
        ,l_camflg            char(01)
        ,l_qtd               integer
        ,l_total_matico      integer
        ,l_total_matico_re   integer
        ,l_total_matico_auto integer
        ,l_soma              integer
        ,l_flag              smallint
        ,l_p_srv_re          decimal(4,2)
        ,l_p_srv_auto        decimal(4,2)
        ,l_p_ac_manual       decimal(4,2)
        ,l_p_ac_matico       decimal(4,2)
        ,l_r9                integer
        ,l_r10               integer
        ,l_r11               integer
        ,l_i                 smallint
        ,l_lidos             smallint
        ,l_pri_etapa         like datmsrvacp.atdetpcod
        ,l_ult_etapa         like datmsrvacp.atdetpcod
        ,l_pri_emp           like datmsrvacp.empcod
        ,l_pri_matri         like datmsrvacp.funmat
        ,l_ult_matri         like datmsrvacp.funmat
        ,l_ult_emp           like datmsrvacp.empcod
        ,l_prslocflg         like datmservico.prslocflg
        ,l_asitipcod         like datmservico.asitipcod
        ,l_vclcoddig         like datmservico.vclcoddig
        ,l_c24astcod         like datmligacao.c24astcod
        ,l_rcfctgatu         like agetdecateg.rcfctgatu
        ,l_res               smallint
        ,l_msg               char(80)
        ,l_p_r1              dec(6,3)
        ,l_p_r2              dec(6,3)
        ,l_p_r3              dec(6,3)
        ,l_p_r4              dec(6,3)
        ,l_p_r5              dec(6,3)
        ,l_p_r6              dec(6,3)
        ,l_p_r7              dec(6,3)
        ,l_p_r8              dec(6,3)
        ,l_p_r9              dec(6,3)
        ,l_p_r10             dec(6,3)
        ,l_p_r11             dec(6,3)
        ,l_p_tot             dec(6,3)
        ,l_perc              dec(6,3)
        ,l_tt_perc           dec(6,3)


  let l_acnnaomtv = null
  let l_atdetpcod = null
  let l_atdsrvorg = null
  let l_acnsttflg = null
  let l_atdsrvnum = null
  let l_funmat    = null
  let l_atdsrvano = null
  let l_prslocflg = null
  let l_cidnom    = null
  let l_ufdcod    = null
  let l_asitipcod = null
  let l_vclcoddig = null
  let l_rcfctgatu = null
  let l_msg       = null
  let l_res       = null
  let l_lclltt    = null
  let l_lcllgt    = null
  let l_motivo    = null
  let l_qtd       = null
  let l_camflg    = null
  let l_c24astcod = null
  let l_pri_etapa = null
  let l_ult_etapa = null
  let l_pri_matri = null
  let l_ult_matri = null
  let l_pri_emp   = null
  let l_ult_emp   = null

  let l_total_geral       = 0
  let l_total_auto        = 0
  let l_total_re          = 0
  let l_soma              = 0
  let l_total_manual      = 0
  let l_r9                = 0
  let l_r10               = 0
  let l_r11               = 0
  let l_total_manual_re   = 0
  let l_total_manual_auto = 0
  let l_total_matico      = 0
  let l_total_matico_re   = 0
  let l_total_matico_auto = 0
  let l_p_srv_re          = 0
  let l_p_srv_auto        = 0
  let l_p_ac_manual       = 0
  let l_p_ac_matico       = 0
  let l_i     = 0
  let l_lidos = 0
  let l_p_r1  = 0
  let l_p_r2  = 0
  let l_p_r3  = 0
  let l_p_r4  = 0
  let l_p_r5  = 0
  let l_p_r6  = 0
  let l_p_r7  = 0
  let l_p_r8  = 0
  let l_p_r9  = 0
  let l_p_r10 = 0
  let l_p_r11 = 0
  let l_p_tot = 0
  let l_perc  = 0
  let l_tt_perc = 0


  open cbdata096001 using m_data

  foreach cbdata096001 into l_funmat, l_acnnaomtv, l_atdetpcod,
                            l_atdsrvorg, l_atdsrvnum, l_atdsrvano,
                            l_acnsttflg, l_prslocflg, l_asitipcod,
                            l_vclcoddig

     if l_atdsrvorg <> 1  and
        l_atdsrvorg <> 2  and
        l_atdsrvorg <> 3  and
        l_atdsrvorg <> 4  and
        l_atdsrvorg <> 5  and
        l_atdsrvorg <> 6  and
        l_atdsrvorg <> 7  and
        l_atdsrvorg <> 9  and
        l_atdsrvorg <> 17 then
        continue foreach
     end if

     let l_flag = 1

     # -> CONTABILIZA O TOTAL GERAL DE SERVICOS LIDOS
     let l_total_geral = (l_total_geral + 1)
     let l_lidos       = (l_lidos + 1)

     if l_lidos >= 10000 then
        display "LIDOS ATE O MOMENTO: ", l_lidos using "<<<<&"
        let l_lidos = 0
     end if

     if l_funmat = 999999 then
        # -> TOTAL DE SERVICOS ACIONADOS AUTOMATICO
        let l_total_matico = (l_total_matico + 1)

        if l_atdetpcod = 3 then # TOTAL AUTOMATICO RE
           let l_total_matico_re =   (l_total_matico_re + 1)
        else                    # TOTAL AUTOMATICO AUTO
           let l_total_matico_auto = (l_total_matico_auto + 1)
        end if
        continue foreach
     end if

     # -> TOTAL DE SERVICOS ACIONADOS MANUAL
     let l_total_manual = (l_total_manual + 1)

     if l_atdetpcod = 3 then # TOTAL MANUAL RE
        let l_total_manual_re =   (l_total_manual_re + 1)
     else                    # TOTAL MANUAL AUTO
        let l_total_manual_auto = (l_total_manual_auto + 1)
     end if

     case l_acnnaomtv

     when ("NAO LOCALIZOU SOCORRISTA ADEQUADO.")
          execute pbdata096005 using l_flag,l_acnnaomtv,
                                     l_atdsrvnum,l_atdsrvano

     when ("NAO LOCALIZOU SOCORRISTA ESPECIALIZADO.")
          execute pbdata096005 using l_flag,l_acnnaomtv,
                                     l_atdsrvnum,l_atdsrvano

     when ("ERRO DE ACESSO A BASE DE DADOS.")
          execute pbdata096005 using l_flag,l_acnnaomtv,
                                     l_atdsrvnum,l_atdsrvano

     when ("VEIC. EM RODIZIO FORA DA DISTAN. LIMITE.")
          execute pbdata096005 using l_flag,l_acnnaomtv,
                                     l_atdsrvnum,l_atdsrvano

     when ("NAO LOCALIZ. SOCOR. ESPECI. P/SRV. MULT.")
          execute pbdata096005 using l_flag,l_acnnaomtv,
                                     l_atdsrvnum,l_atdsrvano

     when ("NAO LOCALIZ. SOCOR. ADEQ. P/SRV. MULTIP.")
          execute pbdata096005 using l_flag,l_acnnaomtv,
                                     l_atdsrvnum,l_atdsrvano

     when ("NAO LOCALI. VEIC. DISP. LIMITE PARAMETR.")
          execute pbdata096005 using l_flag,l_acnnaomtv,
                                     l_atdsrvnum,l_atdsrvano

     when ("PROBLEMAS NO CALCULO DA DISTANCIA")
          execute pbdata096005 using l_flag,l_acnnaomtv,
                                     l_atdsrvnum,l_atdsrvano

     when ("ERRO NA ROTEIRIZACAO.")
          execute pbdata096005 using l_flag,l_acnnaomtv,
                                     l_atdsrvnum,l_atdsrvano

     when ("DIVERGENCIA: CAD. EXECOES E LOCA/COND.")
          execute pbdata096005 using l_flag,l_acnnaomtv,
                                     l_atdsrvnum,l_atdsrvano

     when ("PRESTADOR NAO CONECTADO NO PORTAL")
          execute pbdata096005 using l_flag,l_acnnaomtv,
                                     l_atdsrvnum,l_atdsrvano

     when ("SRV. C/LATITUDE OU LONGITUDE NULAS")
          execute pbdata096005 using l_flag,l_acnnaomtv,
                                     l_atdsrvnum,l_atdsrvano

     when ("PRESTADOR RECEBE POR FAX.")
          execute pbdata096005 using l_flag,l_acnnaomtv,
                                     l_atdsrvnum,l_atdsrvano

     when ("TECNICO ACIONADO EM 24/48H INDISPONIVEL")
          execute pbdata096005 using l_flag,l_acnnaomtv,
                                     l_atdsrvnum,l_atdsrvano

     when ("NAO LOCALIZOU PRESTAD. PARAMETR. P/SERV.")
          execute pbdata096005 using l_flag,l_acnnaomtv,
                                     l_atdsrvnum,l_atdsrvano

     when ("TECNICO ACIONADO 24/48H EM RODIZIO.")
          execute pbdata096005 using l_flag,l_acnnaomtv,
                                     l_atdsrvnum,l_atdsrvano

     when ("TECNICO ACIONADO EM 24/48H NAO ADEQUADO.")
          execute pbdata096005 using l_flag,l_acnnaomtv,
                                     l_atdsrvnum,l_atdsrvano

     when ("TECN. ACION. 24/48H N ADEQ. P/SRV. MULT.")
          execute pbdata096005 using l_flag,l_acnnaomtv,
                                     l_atdsrvnum,l_atdsrvano

     when ("NAO ENCONTROU PRESTADOR DISPONIVEL")
          execute pbdata096005 using l_flag,l_acnnaomtv,
                                     l_atdsrvnum,l_atdsrvano

     when ("SERVICO SEM LATITUDE OU LONGITUDE")
          execute pbdata096005 using l_flag,l_acnnaomtv,
                                     l_atdsrvnum,l_atdsrvano

     when ("LIMITE TEMPO EXCEDIDO P/ACIONAMENTO AUTO")
          execute pbdata096005 using l_flag,l_acnnaomtv,
                                     l_atdsrvnum,l_atdsrvano

     otherwise
        if l_acnnaomtv is not null then
           # -> CONTA COMO DESCONECTADO DO PORTAL
           let l_acnnaomtv = "PRESTADOR NAO CONECTADO NO PORTAL"
           execute pbdata096005 using l_flag,l_acnnaomtv,
                                      l_atdsrvnum,l_atdsrvano
        else
           # -> MOTIVO E NULO, MAS O SERVICO NAO FOI PARA O ACIONAMENTO
           if l_acnsttflg is null then
              # -> SERVICO NAO FOI PARA O ACIONAMENTO
              let l_acnnaomtv = "SERV. QUE NAO FORAM PARA O ACIONAMENTO"
              execute pbdata096005 using l_flag,l_acnnaomtv,
                                         l_atdsrvnum,l_atdsrvano

              let l_res = 0
              let l_msg = null
              let l_c24astcod = null

              # -> BUSCA O ASSUNTO DO SERVICO
              call ctd06g00_pri_ligacao(1,l_atdsrvnum, l_atdsrvano)
                   returning l_res, l_msg, l_c24astcod

              let l_res = 0
              let l_msg = null
              let l_cidnom = null
              let l_ufdcod = null
              let l_lclltt = null
              let l_lcllgt = null

              # -> BUSCA A LATITUDE E LONGITUDE DO SERVICO
              call ctd07g03_busca_local(1, l_atdsrvnum, l_atdsrvano, 1)
                   returning l_res, l_msg, l_cidnom, l_ufdcod,
                                           l_lclltt, l_lcllgt

              let l_res = 0
              let l_msg = null
              let l_rcfctgatu = null

              # -> BUSCA CATEGORIA TARIFARIA DO VEICULO
              call cty05g03_pesq_catgtf(l_vclcoddig,today)
                   returning l_res,
                             l_msg,
                             l_rcfctgatu

              call cts02m01_ctgtrfcod(l_rcfctgatu)
                  returning l_camflg


              {if l_rcfctgatu = 40 or
                 l_rcfctgatu = 41 or
                 l_rcfctgatu = 42 or
                 l_rcfctgatu = 43 or
                 l_rcfctgatu = 50 or
                 l_rcfctgatu = 51 or
                 l_rcfctgatu = 52 or
                 l_rcfctgatu = 43 then
                 let l_camflg = "S"
              else
                 let l_camflg = "N"
              end if}

              # -> VERIFICA O PORQUE NAO FOI P/ACIONAMENTO
              if not cts34g00_acion_auto(l_atdsrvorg,
                                         l_cidnom,
                                         l_ufdcod) then
                 let l_acnnaomtv = g_motivo ## carregado no cts34g00
                 let l_r10 = (l_r10 + 1)
                 #let l_acnnaomtv = "ACIONAMENTO DESATIVADO(cts34g00)"
                 let l_flag = 2
                 execute pbdata096005 using l_flag, l_acnnaomtv,
                                            l_atdsrvnum,l_atdsrvano
                 continue foreach
              end if

              call cts40g12_avalia_regras(l_atdsrvorg, l_c24astcod,
                                          l_asitipcod, l_lclltt,
                                          l_lcllgt, l_prslocflg,
                                          "N", l_atdsrvnum,
                                          l_atdsrvano, l_c24astcod,
                                          l_vclcoddig, l_camflg)
                   returning l_aciona

             if l_aciona = false then
                let l_acnnaomtv = g_motivo ## carregado no cts40g12
                let l_flag = 2
                execute pbdata096005 using l_flag, l_acnnaomtv,
                                           l_atdsrvnum,l_atdsrvano
             end if

             if l_aciona = true then

                let l_res = 0
                let l_msg = null
                let l_pri_emp   = null
                let l_pri_matri = null
                let l_pri_etapa = null

                # -> BUSCA A PRIMEIRA MATRICULA E ETAPA DE ACIONAMENTO
                call ctd07g05_pri_acn(1,l_atdsrvnum, l_atdsrvano)
                     returning l_res, l_msg, l_pri_emp, l_pri_matri, l_pri_etapa

                let l_res = 0
                let l_msg = null
                let l_ult_emp   = null
                let l_ult_matri = null
                let l_ult_etapa = null

                # -> BUSCA A ULTIMA MATRICULA E ETAPA DE ACIONAMENTO
                call ctd07g05_ult_acn(1,l_atdsrvnum, l_atdsrvano)
                     returning l_res, l_msg, l_ult_emp, l_ult_matri, l_ult_etapa

                 if l_pri_matri = l_ult_matri then
                    let l_r9 = (l_r9 + 1)
                    let l_acnnaomtv = "SERVICO ACIONADO PELO ATENDENTE"
                    let l_flag = 2
                    execute pbdata096005 using l_flag, l_acnnaomtv,
                                          l_atdsrvnum, l_atdsrvano
                    continue foreach

                 else
                    let l_r11 = (l_r11 + 1)
                    let l_acnnaomtv = "SEM REGRA"
                    let l_flag = 2
                    execute pbdata096005 using l_flag, l_acnnaomtv,
                                          l_atdsrvnum, l_atdsrvano
                    continue foreach
                  end if
             end if

           else

              # -> SERVICO FOI PARA ACIONAMENTO E ESTA SEM MOTIVO

              let l_flag = 1
              let l_res = 0
              let l_msg = null
              let l_pri_emp   = null
              let l_pri_matri = null
              let l_pri_etapa = null

              # -> BUSCA A PRIMEIRA ETAPA DE ACIONAMENTO
              call ctd07g05_pri_acn(1,l_atdsrvnum, l_atdsrvano)
                   returning l_res, l_msg, l_pri_emp, l_pri_matri, l_pri_etapa

              if l_pri_etapa = 4 or
                 l_pri_etapa = 3 or
                 l_pri_etapa = 43 then

                 if l_pri_matri <> 999999 then
                    let l_acnnaomtv = "INTERVENCAO MANUAL ANTES AC/AUTOMATICO"
                    execute pbdata096005 using l_flag, l_acnnaomtv,
                                          l_atdsrvnum, l_atdsrvano
                    continue foreach
                 end if
              end if

              let l_res = 0
              let l_msg = null
              let l_ult_emp   = null
              let l_ult_matri = null
              let l_ult_etapa = null

              # -> BUSCA A ULTIMA MATRICULA E ETAPA DE ACIONAMENTO
              call ctd07g05_ult_acn(1,l_atdsrvnum, l_atdsrvano)
                   returning l_res, l_msg, l_ult_emp, l_ult_matri, l_ult_etapa

              if (l_pri_matri = 999999 and l_ult_matri <> 999999) then
                 let l_acnnaomtv = "INTERVENCAO MANUAL APOS AC/AUTOMATICO"
                 execute pbdata096005 using l_flag, l_acnnaomtv,
                                       l_atdsrvnum, l_atdsrvano
                 continue foreach
              end if

              if l_pri_matri <> 999999 and l_ult_matri <> 999999 and
                 l_pri_matri <> l_ult_matri then

                 let l_res = 0
                 let l_msg = null
                 let l_dptsgl = null

                 call cty08g00_depto_func(l_ult_emp, l_ult_matri, "F")
                      returning l_res, l_msg, l_dptsgl

                 if l_dptsgl <> 'ct24hs' and
                    l_dptsgl <> 'dsvatd' then

                    if l_dptsgl = 'psocor' then
                       let l_acnnaomtv = "SERVICOS ACIONADOS PELO PORTO SOCORRO"
                       execute pbdata096005 using l_flag, l_acnnaomtv,
                                             l_atdsrvnum,l_atdsrvano
                       continue foreach
                    else
                       let l_acnnaomtv = "SERVICOS ACIONADOS POR OUTROS DEPTOS."
                       execute pbdata096005 using l_flag, l_acnnaomtv,
                                             l_atdsrvnum,l_atdsrvano
                       continue foreach
                    end if

                 end if

              end if

              let l_acnnaomtv = "SEM MOTIVO"
              execute pbdata096005 using l_flag, l_acnnaomtv,
                                    l_atdsrvnum,l_atdsrvano

           end if

        end if

     end case

  end foreach

  close cbdata096001

  start report r_bdata096_doc to m_path1

  let m_hora = current
  display 'Gerando arquivo r_bdata096_doc ', m_hora

  # -> TOTAL DE SERVICOS AUTO
  let l_total_auto  = (l_total_manual_auto + l_total_matico_auto)

  # -> TOTAL DE SERVICOS RE
  let l_total_re    = (l_total_manual_re   + l_total_matico_re)

  # -> PORCENTAGENS
  let l_p_srv_re    = ((l_total_re     * 100)/l_total_geral)
  let l_p_srv_auto  = ((l_total_auto   * 100)/l_total_geral)

  let l_p_ac_manual = ((l_total_manual * 100)/l_total_geral)
  let l_p_ac_matico = ((l_total_matico * 100)/l_total_geral)

  let l_motivo = null
  let l_qtd    = null
  let l_soma   = null

  # -> LE A SOMA DAS QUANTIDADES DE MOTIVOS
  let l_flag = 1
  open cbdata096006 using l_flag
  fetch cbdata096006 into l_soma
  close cbdata096006

  # -> LE OS REGISTROS DA TEMPORARIA
  open cbdata096002
  foreach cbdata096002 into l_motivo, l_qtd

     let l_perc = ((l_qtd * 100) / l_soma)
     let l_tt_perc = l_tt_perc + l_perc

     output to report r_bdata096_doc (l_total_geral,
                                      l_total_re, l_p_srv_re,
                                      l_total_auto, l_p_srv_auto,
                                      l_total_manual, l_p_ac_manual,
                                      l_total_manual_re, l_total_manual_auto,
                                      l_total_matico, l_p_ac_matico,
                                      l_total_matico_re, l_total_matico_auto,
                                      l_motivo, l_qtd, l_perc,
                                      l_soma, l_tt_perc, 1)


  end foreach

  close cbdata096002
  finish report r_bdata096_doc

  start report r_lev to m_path2
  
  let m_hora = current                                   
  display 'Gerando arquivo r_lev ', m_hora      
  
  open cbdata096004
  foreach cbdata096004 into l_motivo, l_atdsrvnum, l_atdsrvano

          if l_motivo = "SERV. QUE NAO FORAM PARA O ACIONAMENTO" then
             continue foreach
          end if

          output to report r_lev(l_motivo, l_atdsrvnum, l_atdsrvano)

  end foreach

  finish report r_lev
  close cbdata096004

end function

function bdata096_email()

  define lr_mail record
     rem     char(50)
    ,des     char(10000)
    ,ccp     char(10000)
    ,cco     char(10000)
    ,ass     char(500)
    ,msg     char(32000)
    ,idr     char(20)
    ,tip     char(4)
  end record
  
  define lr_anexo record
     anexo1    char (300)
    ,anexo2    char (300)
    ,anexo3    char (300)
  end record
  
  define   lr_mail_erro   smallint
  define   l_cmd          char(500)
  define   l_destino      char(1500)     

  initialize lr_mail.*, lr_anexo.* to null
  let l_cmd = null

  declare cur6 cursor for
          select cpodes, cpocod from iddkdominio
           where cponom = 'acionamento'  
           order by 2

  foreach cur6 into l_destino
        if lr_mail.des is null then
           let lr_mail.des = l_destino
        else
           let lr_mail.des = lr_mail.des clipped,',',l_destino
        end if
  end foreach
  
     let l_cmd = "gzip -f ", m_path1
     run l_cmd
     let m_path1 = m_path1 clipped, ".gz"
     let lr_anexo.anexo1 = m_path1
     
     let l_cmd = "gzip -f ", m_path2
     run l_cmd    
     let m_path2 = m_path2 clipped, ".gz"
     let lr_anexo.anexo2 = m_path2
     
     let lr_mail.rem = "EmailCorr.ct24hs@correioporto"
     let lr_mail.msg = "bdata096"
     let lr_mail.idr = 'P0603000' 
     let lr_mail.tip = 'text'
     let lr_mail.ass = "Levantamento Diario dos Acionamentos em ", m_data


 display 'Enviando e-mail para: ', lr_mail.des  clipped

     let lr_mail_erro = ctx22g00_envia_email_anexos(lr_mail.*, lr_anexo.*)
     
     if  lr_mail_erro <> 0 then                             
         if  lr_mail_erro <> 99 then
             display "Erro ao enviar email(ctx22g00) - ", lr_mail_erro
         else
             display "Nao existe email cadastrado para o modulo - BDBSR130"
         end if
     end if

end function



report r_bdata096_doc (l_total_geral,
                       l_total_re, l_p_srv_re,
                       l_total_auto, l_p_srv_auto,
                       l_total_manual, l_p_ac_manual,
                       l_total_manual_re, l_total_manual_auto,
                       l_total_matico, l_p_ac_matico,
                       l_total_matico_re, l_total_matico_auto,
                       l_motivo, l_qtd, l_perc, l_soma, l_tt_perc, l_flag)

   define l_total_geral       integer,
          l_total_re          integer,
          l_p_srv_re          decimal(4,2),
          l_total_auto        integer,
          l_p_srv_auto        decimal(4,2),
          l_total_manual      integer,
          l_p_ac_manual       decimal(4,2),
          l_total_manual_re   integer,
          l_total_manual_auto integer,
          l_total_matico      integer,
          l_p_ac_matico       decimal(4,2),
          l_total_matico_re   integer,
          l_total_matico_auto integer,
          l_motivo            char(40),
          l_qtd               integer,
          l_perc              dec(6,3),
          l_soma              integer,
          l_tt_perc           dec(6,3),
          l_flag              smallint,
          l_tt_perc1          dec(6,3)

   output
      left   margin  000
      top    margin  000
      bottom margin  000

   format
     first page header

        print " "
        print "PERIODO DE EXTRACAO: ", m_data, " ATE ", m_data
        print "-------------------------------------------------------------"
        print "TOTAL DE SERVICOS ACIONADOS...........: ",
                l_total_geral       using "<<<<<<<<&"
        print "      RE..............................: ",
                l_total_re          using "<<<<<<<<&", "  ", "(",
                l_p_srv_re          using "<<<&.&&", "%", ")"
        print "      AUTO............................: ",
                l_total_auto        using "<<<<<<<<&", "  ", "(",
                l_p_srv_auto        using "<<<&.&&", "%", ")"
        print "-------------------------------------------------------------"

        print "TOTAL DE SERVICOS ACIONADOS MANUAL....: ",
                l_total_manual      using "<<<<<<<<&", "  ", "(",
                l_p_ac_manual       using "<<<&.&&", "%", ")"
        print "      RE..............................: ",
                l_total_manual_re   using "<<<<<<<<&"
        print "      AUTO............................: ",
                l_total_manual_auto using "<<<<<<<<&"
        print "-------------------------------------------------------------"
        print "TOTAL DE SERVICOS ACIONADOS AUTOMATICO: ",
                l_total_matico      using "<<<<<<<<&", "  ", "(",
                l_p_ac_matico       using "<<<&.&&", "%", ")"
        print "      RE..............................: ",
                l_total_matico_re   using "<<<<<<<<&"
        print "      AUTO............................: ",
                l_total_matico_auto using "<<<<<<<<&"
        print "-------------------------------------------------------------"
        print "   ****** MOTIVOS DE NAO ACIONAMENTO ******   "
        print "-------------------------------------------------------------"

  on every row

     print "  ", l_motivo, "    ",
                 l_qtd    using "####&", "   ", l_perc using "#&.&&"," %"

     if l_motivo = "SERV. QUE NAO FORAM PARA O ACIONAMENTO" then

        skip 1 line

        let l_flag = 2
        let l_tt_perc1 = 0
        open cbdata096006 using l_flag
        fetch cbdata096006 into l_soma
        close cbdata096006

        open cbdata096003
        foreach cbdata096003 into l_motivo, l_qtd
                let l_perc  = ((l_qtd  * 100)/l_soma)
                print "   ", l_motivo, " ",
                       l_qtd   using "####&", " ", l_perc using "##&.&&"," %"
                let l_tt_perc1 = l_tt_perc1 + l_perc
        end foreach

        close cbdata096003

        print "    ------------------------------------------------------"
        print "    TOTAL.................................: ",
                l_soma using "####&", " ",l_tt_perc1 using "##&.&&" ," %"
        print "    ------------------------------------------------------"
        skip 1 line

     end if


  on last row
     print "-------------------------------------------------------------"
     print "  TOTAL................................: ",
             l_soma using "#########&", "  ", l_tt_perc using "##&.&&"," %"
     print "-------------------------------------------------------------"

end report

report r_lev(l_motivo, l_atdsrvnum, l_atdsrvano)

   define  l_motivo            char(40),
           l_atdsrvnum         like datmservico.atdsrvnum,
           l_atdsrvano         like datmservico.atdsrvano

   output
      left   margin  000
      top    margin  000
      bottom margin  000

   format

   first page header
      print "MOTIVO", ASCII(09),
            "SERVICO", ASCII(09),
            "ANO"

   on every row
      print l_motivo, ASCII(09),
            l_atdsrvnum, ASCII(09),
            l_atdsrvano

end report
