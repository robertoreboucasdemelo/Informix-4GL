#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: CTS40G12                                                   #
# ANALISTA RESP..: LIGIA MARIA MATTGE                                         #
# PSI/OSF........: 198714 - ACIONAMENTO AUTOMATICO AUTOMOVEL.                 #
#                  REGRAS P/ACIONAR UM SERVICO AUTOMATICAMENTE.               #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID/PRISCILA STAINGEL                             #
# LIBERACAO......: 28/06/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 06/12/2006  Ligia Mattge   CT/PSI     c24lclpdrcod                         #
# ---------- --------------  ---------- ------------------------------------- #
# 02/07/2008  Carla Rampazzo             g_origem identifica quem chama:      #
#                                        "IFX"/null=Informix / "WEB"=Portal   #
# 28/01/2009   Adriano Santos  PSI235849 Considerar serviço SINISTRO RE       #
# 02/03/2010   Adriano Santos  PSI252891 Inclusao do padrao idx 4 e 5         #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

  define m_cts40g12_prep smallint

#-----------------------------------------------------------------------------#
function cts40g12_prepare()
#-----------------------------------------------------------------------------#

  define l_sql char(300)

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_sql = null

  let l_sql = " select atmacnflg ",
                " from datkassunto ",
               " where c24astcod = ? "

  prepare p_cts40g12_001 from l_sql
  declare c_cts40g12_001 cursor for p_cts40g12_001

  let l_sql = " select atmacnflg ",
                " from datkasitip ",
               " where asitipcod = ? "

  prepare p_cts40g12_002 from l_sql
  declare c_cts40g12_002 cursor for p_cts40g12_002

  let l_sql = " select atmacnflg ",
                " from datkvclcndlcl ",
               " where vclcndlclcod = ? "

  prepare p_cts40g12_003 from l_sql
  declare c_cts40g12_003 cursor for p_cts40g12_003

  let l_sql = " update datmservico set ",
                    " (acntntqtd, ",
                     " acnsttflg, ",
                     " atdfnlflg) = (0,'N',?) ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare p_cts40g12_004 from l_sql

  let l_sql = " select vclcndlclcod ",
                " from datrcndlclsrv ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare p_cts40g12_005 from l_sql
  declare c_cts40g12_005 cursor for p_cts40g12_005

  let l_sql = " select 1 ",
                " from datrctggch ",
               " where ctgtrfcod = ? "

  prepare p_cts40g12_006 from l_sql
  declare c_cts40g12_006 cursor for p_cts40g12_006

  let l_sql = " select atdfnlflg, ",
                     " acnsttflg, ",
                     " atdlibflg ",
                " from datmservico ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare p_cts40g12_007 from l_sql
  declare c_cts40g12_007 cursor for p_cts40g12_007

  let l_sql = " select cidnom, ufdcod, c24lclpdrcod ",
                " from datmlcl ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? ",
                 " and c24endtip  = 1 "

  prepare p_cts40g12_008 from l_sql
  declare c_cts40g12_008 cursor for p_cts40g12_008

  let l_sql = " select cpocod ",
                " from datkdominio ",
               " where cponom = 'cidacngpssemidx' ",
                 " and cpodes = ? "

  prepare p_cts40g12_009 from l_sql
  declare c_cts40g12_009 cursor for p_cts40g12_009


  let m_cts40g12_prep = true

end function

#-----------------------------------------------------------------------------#
function cts40g12_regras_aciona_auto(lr_parametro)
#-----------------------------------------------------------------------------#

  define lr_parametro record
         atdsrvorg    like datmservico.atdsrvorg,      # ORIGEM DO SERVICO
         c24astcod    like datkassunto.c24astcod,      # ASSUNTO DO SERVICO
         asitipcod    like datkasitip.asitipcod,       # COD. TIPO DE ASSISTENCIA DO SERVICO
         lclltt       like datmlcl.lclltt,             # LATITUDE DO SERVICO
         lcllgt       like datmlcl.lcllgt,             # LONGITUDE DO SERVICO
         prslocflg    char(01),                        # FLAG DE PRESTADOR NO LOCAL
         frmflg       char(01),                        # FLAG ATENDIMENTO VIA FORMULARIO
         atdsrvnum    like datmservico.atdsrvnum,      # NUMERO DO SERVICO
         atdsrvano    like datmservico.atdsrvano,      # ANO DO SERVICO
         acao         char(03),                        # ACAO DO SERVICO
         vclcoddig    like datmservico.vclcoddig,      # CODIGO DO VEÍCULO
         camflg       char(1)                          # CAM/UTIL  S/N
  end record

  define l_aciona     char(01),
         l_motivo     char(40),
         l_aa_parado  smallint

  #----------------------------
  # INICIALIZACAO DAS VARIAVEIS
  #----------------------------

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_aciona  =  null
        let     l_motivo  =  null
        let     l_aa_parado  =  null

  call cts40g12_avalia_regras(lr_parametro.*)
       returning l_aciona

  if l_aciona then

     ### Comentado por Raji 23/06/2009
     ####----------------------------------------------
     #### VERIFICA SE ACIONAMENTO AUTOMATICO ESTA ATIVO
     ####----------------------------------------------
     ### call cts40g12_ver_aa(lr_parametro.atdsrvorg)
     ###         returning l_aa_parado, l_motivo
     ###
     ### if l_aa_parado = true then ##SE ESTIVER PARADO
     ###    let l_aciona = false
     ### end if

     #----------------------------------------------
     # ENVIA O SERVICO PARA O ACIONAMENTO AUTOMATICO
     #----------------------------------------------
     call cts40g12_atl_datmservico(lr_parametro.atdsrvnum,
                                   lr_parametro.atdsrvano,
                                   "A")
  end if

  return l_aciona

end function

#-----------------------------------------------------------------------------#
function cts40g12_avalia_regras(lr_parametro)
#-----------------------------------------------------------------------------#

  define lr_parametro record
         atdsrvorg    like datmservico.atdsrvorg,      # ORIGEM DO SERVICO
         c24astcod    like datkassunto.c24astcod,      # ASSUNTO DO SERVICO
         asitipcod    like datkasitip.asitipcod,       # COD. TIPO DE ASSISTENCIA DO SERVICO
         lclltt       like datmlcl.lclltt,             # LATITUDE DO SERVICO
         lcllgt       like datmlcl.lcllgt,             # LONGITUDE DO SERVICO
         prslocflg    char(01),                        # FLAG DE PRESTADOR NO LOCAL
         frmflg       char(01),                        # FLAG ATENDIMENTO VIA FORMULARIO
         atdsrvnum    like datmservico.atdsrvnum,      # NUMERO DO SERVICO
         atdsrvano    like datmservico.atdsrvano,      # ANO DO SERVICO
         acao         char(03),                        # ACAO DO SERVICO
         vclcoddig    like datmservico.vclcoddig,      # CODIGO DO VEÍCULO
         camflg       char(1)                          # CAM/UTIL  S/N
  end record

  define l_aciona     char(01),
         l_atmacnflg  like datkassunto.atmacnflg

  define l_data       date,
         l_hora2      datetime hour to minute

  define l_aux        smallint,
         l_msg        char(80),
         l_chave_par  like datkgeral.grlchv,
         l_chave_atl  like datkgeral.grlchv,
         l_rcfctgatu  like agetdecateg.rcfctgatu,
         l_status     smallint,
         l_tempo_par  datetime hour to second,
         l_tempo_atl  datetime hour to second,
         l_agora      datetime hour to second,
         l_dif_tempo  interval hour to second,
         l_tempo_int  interval hour to second,
         l_motivo     char(40),
         l_aa_parado  smallint,
         l_hora_char  char(12)

  #----------------------------
  # INICIALIZACAO DAS VARIAVEIS
  #----------------------------

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_aciona  =  null
        let     l_atmacnflg  =  null
        let     l_data  =  null
        let     l_hora2  =  null
        let     l_aux  =  null
        let     l_msg  =  null
        let     l_chave_par  =  null
        let     l_chave_atl  =  null
        let     l_rcfctgatu  =  null
        let     l_status  =  null
        let     l_tempo_par  =  null
        let     l_tempo_atl  =  null
        let     l_agora  =  null
        let     l_dif_tempo  =  null
        let     l_tempo_int  =  null
        let     l_motivo  =  null
        let     l_aa_parado  =  null
        let     l_hora_char  =  null

  let l_aciona    = true
  let l_aux       = 0

  if m_cts40g12_prep is null or
     m_cts40g12_prep <> true then
     call cts40g12_prepare()
  end if

  if lr_parametro.atdsrvorg is null or
     lr_parametro.c24astcod is null or
     lr_parametro.frmflg is null    or
     lr_parametro.frmflg = "S"      or
     lr_parametro.atdsrvnum is null or
     lr_parametro.atdsrvano is null or
     lr_parametro.camflg = "S" then
     let l_aciona = false
     let g_r1 = g_r1 + 1
     let g_motivo = "VEICULO E UM CAMINHAO"

  else
     call cts40g12_ver_indexacao(lr_parametro.lclltt, lr_parametro.lcllgt,
                                 lr_parametro.atdsrvnum, lr_parametro.atdsrvano,
                                 lr_parametro.atdsrvorg)
          returning l_aciona

     if l_aciona = false then
        let g_r2 = g_r2 + 1
        let g_motivo = "SERVICO NAO INDEXADO"
     end if
     #-----------------------------------
     # CASO ESPECIFICO PARA ORIGEM 9 - RE
     #-----------------------------------
     #if lr_parametro.atdsrvorg = 9 and
     #   lr_parametro.acao = "RET" then
     #   return l_aciona
     #end if

     if l_aciona = true then
        #--------------------------------------------------
        # BUSCA O FLAG DE ACIONAMENTO NA TABELA datkassunto
        #--------------------------------------------------
        let l_atmacnflg = cts40g12_busca_flg_datkassunto(lr_parametro.c24astcod)

        if l_atmacnflg is null or
           l_atmacnflg = "N" then
           let g_r3 = g_r3 + 1
           let g_motivo = "ASSUNTO NAO PARAMETRIZADO"
           let l_aciona = false
        else
           if lr_parametro.atdsrvorg = 1 or
              lr_parametro.atdsrvorg = 2 or
              lr_parametro.atdsrvorg = 4 or
              lr_parametro.atdsrvorg = 6 or
              lr_parametro.atdsrvorg = 9 or
              lr_parametro.atdsrvorg = 13 then # PSI 235849 Adriano Santos 28/01/2009
              if lr_parametro.prslocflg = "S" then
                 let l_aciona = false
                 let g_r4 = g_r4 + 1
                 let g_motivo = "ORIGEM(1,2,4,6,9,13) E PREST. NO LOCAL:"
              end if
           end if

           if lr_parametro.atdsrvorg <> 9 and lr_parametro.atdsrvorg <> 13 then # PSI 235849 Adriano Santos 28/01/2009
              if l_aciona then
                 #-------------------------------------------------
                 # BUSCA O FLAG DE ACIONAMENTO NA TABELA datkasitip
                 #-------------------------------------------------
                 let l_atmacnflg = cts40g12_busca_flg_datkasitip(lr_parametro.asitipcod)

                 if l_atmacnflg is null or
                    l_atmacnflg = "N" then
                    let l_aciona = false
                    let g_r5 = g_r5 + 1
                    let g_motivo = "ASSISTENCIA NAO PARAMETRIZADA"
                 else
                    if lr_parametro.atdsrvorg <> 2 and
                       lr_parametro.atdsrvorg <> 3 then
                       #se atdsrvorg = 1 ou 4 ou 5 ou 6 ou 7 ou 17
                       #-----------------------------------------
                       # VERIFICA OS TIPOS ASSITENCIAS DO SERVICO
                       #-----------------------------------------
                       if cts40g12_busca_vclcndlclcod(lr_parametro.atdsrvnum,
                                                      lr_parametro.atdsrvano) then
                          let l_aciona = true
                       else
                          let l_aciona = false
                          let g_r6 = g_r6 + 1
                          let g_motivo = "LOCAL CONDICAO NAO PARAMETRIZADO"
                       end if

                       if l_aciona then
                          #-----------------------------------------
                          # VERIFICA GUINCHO PARA CATEGORIA TARIFARIA
                          #------------------------------------------
                          call cts40g03_data_hora_banco(2)
                               returning l_data, l_hora2
                          #busca a categoria tarifaria do veiculo
                          call cty05g03_pesq_catgtf(lr_parametro.vclcoddig,l_data)
                               returning l_aux, l_msg, l_rcfctgatu
                          if l_aux <> 0 then
                             let l_aciona = false
                             let g_r7 = g_r7 + 1
                             let g_motivo = "NAO ENCONTROU A CATEGORIA TARIFARIA"
                          else
                             #verificar se categoria tarifaria tem guincho cadastrado
                             open c_cts40g12_006 using l_rcfctgatu
                             foreach c_cts40g12_006 into l_aux
                                 let l_aciona = true
                                 exit foreach
                             end foreach
                             close c_cts40g12_006
                             if l_aux <> 1 then  #nao encontrou guincho para a cat.tarifaria
                                let l_aciona = false
                                let g_r8 = g_r8 + 1
                                let g_motivo = "NAO ENCONTROU GUINCHO P/CAT.TARIFAR"
                             end if
                          end if

                       end if

                    end if
                 end if
              end if
           end if
        end if
     end if
  end if

  return l_aciona

end function

#-----------------------------------------------------------------------------#
function cts40g12_busca_flg_datkassunto(l_c24astcod)
#-----------------------------------------------------------------------------#

  #------------------------------------------------------------
  # FUNCAO P/BUSCAR O FLAG DE ACIONAMENTO NA TABELA datkassunto
  #------------------------------------------------------------

  define l_c24astcod like datkassunto.c24astcod,
         l_atmacnflg like datkassunto.atmacnflg


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_atmacnflg  =  null

  if m_cts40g12_prep is null or
     m_cts40g12_prep <> true then
     call cts40g12_prepare()
  end if

  open c_cts40g12_001 using l_c24astcod
  whenever error continue
  fetch c_cts40g12_001 into l_atmacnflg
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_atmacnflg = null
     if sqlca.sqlcode <> notfound then

        if g_origem is null   or
           g_origem =  "IFX"  then
           error "Erro SELECT c_cts40g12_001 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 4
           error "cts40g12_busca_flg_datkassunto() / ", l_c24astcod sleep 4
        end if
     end if
  end if

  close c_cts40g12_001

  return l_atmacnflg

end function

#-----------------------------------------------------------------------------#
function cts40g12_busca_flg_datkasitip(l_asitipcod)
#-----------------------------------------------------------------------------#

  #-----------------------------------------------------------
  # FUNCAO P/BUSCAR O FLAG DE ACIONAMENTO NA TABELA datkasitip
  #-----------------------------------------------------------

  define l_asitipcod like datkasitip.asitipcod,
         l_atmacnflg like datkasitip.atmacnflg


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_atmacnflg  =  null

  if m_cts40g12_prep is null or
     m_cts40g12_prep <> true then
     call cts40g12_prepare()
  end if

  open c_cts40g12_002 using l_asitipcod
  whenever error continue
  fetch c_cts40g12_002 into l_atmacnflg
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_atmacnflg = null
     if sqlca.sqlcode <> notfound then

        if g_origem is null   or
           g_origem =  "IFX"  then
           error "Erro SELECT c_cts40g12_002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 4
           error "cts40g12_busca_flg_datkasitip() / ", l_asitipcod sleep 4
        end if
     end if
  end if

  close c_cts40g12_002

  return l_atmacnflg

end function

#-----------------------------------------------------------------------------#
function cts40g12_busca_flg_datkvclcndlcl(l_vclcndlclcod)
#-----------------------------------------------------------------------------#

  #--------------------------------------------------------------
  # FUNCAO P/BUSCAR O FLAG DE ACIONAMENTO NA TABELA datkvclcndlcl
  #--------------------------------------------------------------

  define l_vclcndlclcod like datkvclcndlcl.vclcndlclcod,
         l_atmacnflg    like datkvclcndlcl.atmacnflg


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_atmacnflg  =  null

  if m_cts40g12_prep is null or
     m_cts40g12_prep <> true then
     call cts40g12_prepare()
  end if

  open c_cts40g12_003 using l_vclcndlclcod
  whenever error continue
  fetch c_cts40g12_003 into l_atmacnflg
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let l_atmacnflg = null
     if sqlca.sqlcode <> notfound then

        if g_origem is null   or
           g_origem =  "IFX"  then
           error "Erro SELECT c_cts40g12_003 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 4
           error "cts40g12_busca_flg_datkvclcndlcl() / ", l_vclcndlclcod sleep 4
        end if
     end if
  end if

  close c_cts40g12_003

  return l_atmacnflg

end function

#-----------------------------------------------------------------------------#
function cts40g12_atl_datmservico(lr_parametro)
#-----------------------------------------------------------------------------#

  #---------------------------------------------------------------------------
  # FUNCAO P/ATUALIZAR A DATMSERVICO, ENVIA O SERVICO P/ACIONAMENTO AUTOMATICO
  #---------------------------------------------------------------------------

  define lr_parametro record
         atdsrvnum    like datmservico.atdsrvnum, # NUMERO DO SERVICO
         atdsrvano    like datmservico.atdsrvano, # ANO DO SERVICO
         atdfnlflg    like datmservico.atdfnlflg  # FLAG DE TIPO FINALIZACAO DO SERVICO
  end record

  if m_cts40g12_prep is null or
     m_cts40g12_prep <> true then
     call cts40g12_prepare()
  end if

  call cts40g12_problema(lr_parametro.atdsrvnum,
                         lr_parametro.atdsrvano,
                         lr_parametro.atdfnlflg,
                         "cts40g12.4gl",
                         "cts40g12_atl_datmservico()",
                         "pcts40g12004",
                         g_issk.funmat,
                         "A")

  whenever error continue
  execute p_cts40g12_004 using lr_parametro.atdfnlflg,
                             lr_parametro.atdsrvnum,
                             lr_parametro.atdsrvano
  whenever error stop

  if sqlca.sqlcode <> 0 then

     if g_origem is null   or
        g_origem =  "IFX"  then
        error "Erro UPDATE p_cts40g12_004 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 4
        error "cts40g12_atl_datmservico() / ", lr_parametro.atdfnlflg, "/",
                                            lr_parametro.atdsrvnum, "/",
                                            lr_parametro.atdsrvano sleep 4
     end if
  end if

  call cts40g12_problema(lr_parametro.atdsrvnum,
                         lr_parametro.atdsrvano,
                         lr_parametro.atdfnlflg,
                         "cts40g12.4gl",
                         "cts40g12_atl_datmservico()",
                         "pcts40g12004",
                         g_issk.funmat,
                         "D")

end function

#-----------------------------------------------------------------------------#
function cts40g12_busca_vclcndlclcod(lr_parametro)
#-----------------------------------------------------------------------------#

  #-------------------------------------------------------------
  # FUNCAO P/BUSCAR O CAMPO vclcndlclcod DA TABELA datrcndlclsrv
  #-------------------------------------------------------------

  define lr_parametro record
         atdsrvnum    like datmservico.atdsrvnum,
         atdsrvano    like datmservico.atdsrvano
  end record

  define l_vclcndlclcod like datrcndlclsrv.vclcndlclcod,
         l_atmacnflg    like datkvclcndlcl.atmacnflg,
         l_aciona       smallint


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_vclcndlclcod  =  null
        let     l_atmacnflg  =  null
        let     l_aciona  =  null

  let l_aciona       = true

  if m_cts40g12_prep is null or
     m_cts40g12_prep <> true then
     call cts40g12_prepare()
  end if

  #----------------------------------------------
  # BUSCA OS CODIGOS DO LOCAL/CONDICAO DO VEICULO
  #----------------------------------------------
  open c_cts40g12_005 using lr_parametro.atdsrvnum, lr_parametro.atdsrvano
  foreach c_cts40g12_005 into l_vclcndlclcod

     #----------------------------------------------------------------
     # VERIFICA A SITUACAO DO FLAG DO CODIGO LOCAL/CONDICAO DO VEICULO
     #----------------------------------------------------------------
     let l_atmacnflg = cts40g12_busca_flg_datkvclcndlcl(l_vclcndlclcod)

     if l_atmacnflg is null or
        l_atmacnflg = "N" then
        let l_aciona = false
        exit foreach
     end if

  end foreach
  close c_cts40g12_005

  return l_aciona

end function

#-----------------------------------------------------------------------------#
function cts40g12_ver_aa(l_atdsrvorg)
#-----------------------------------------------------------------------------#

     define l_atdsrvorg like datmservico.atdsrvorg,
            l_chave_par  like datkgeral.grlchv,
            l_chave_atl  like datkgeral.grlchv,
            l_rcfctgatu  like agetdecateg.rcfctgatu,
            l_status     smallint,
            l_tempo_par  datetime hour to second,
            l_tempo_atl  datetime hour to second,
            l_agora      datetime hour to second,
            l_dif_tempo  interval hour to second,
            l_tempo_int  interval hour to second,
            l_motivo     char(40),
            l_hora_char  char(12),
            l_aa_parado  smallint

     #----------------------------------------------------------
     # VERIFICA SE OS ACIONAMENTOS(AUTO OU RE) ESTAO EM EXECUCAO
     #----------------------------------------------------------

     # --> BUSCA AS CHAVES DE PESQUISA

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_chave_par  =  null
        let     l_chave_atl  =  null
        let     l_rcfctgatu  =  null
        let     l_status  =  null
        let     l_tempo_par  =  null
        let     l_tempo_atl  =  null
        let     l_agora  =  null
        let     l_dif_tempo  =  null
        let     l_tempo_int  =  null
        let     l_motivo  =  null
        let     l_hora_char  =  null
        let     l_aa_parado  =  null

     if l_atdsrvorg = 9 then # ACIONAMENTO RE
        let l_chave_par = "PSOARE"
        let l_chave_atl = "BDBSA068"
        let l_motivo    = "ACIONAMENTO AUTOMATICO RE FORA DO AR"
     else # ACIONAMENTO AUTO
        let l_chave_par = "PSOAAUTO"
        let l_chave_atl = "BDBSA069"
        let l_motivo    = "ACIONAMENTO AUTOMATICO AUTO FORA DO AR"
     end if

     # --> BUSCA O TEMPO LIMITE PARAMETRIZADO
     call cts40g03_tempo_param(l_chave_par)
          returning l_status,
                    l_tempo_par

     let l_aa_parado = false

     # --> BUSCA O TEMPO DA ULTIMA ATUALIZACAO DO PROGRAMA BATCH
     call cts40g03_tempo_atlz(l_chave_atl)
          returning l_status,
                    l_tempo_atl

     let l_agora     = current     # HORA ATUAL
     let l_hora_char = l_tempo_par # JOGA PARA VARIAVEL DO TIPO CHAR
     let l_tempo_int = l_hora_char # TRANSFORMA P/ interval hour to second

     # --> CALCULA A DIFERENCA DE TEMPO
     let l_dif_tempo = (l_agora - l_tempo_atl)

     if l_dif_tempo > l_tempo_int then
        # --> TEMPO DE PARADA MAIOR QUE O TEMPO LIMITE PARAMETRIZADO
        let l_aa_parado = true
     end  if

     return l_aa_parado, l_motivo

end function

#-----------------------------------------------------------------------------#
function cts40g12_problema(lr_parametro)
#-----------------------------------------------------------------------------#

  # -> FUNCAO TEMPORARIA PARA IDENTIFICAR O PROBLEMA NO ACIONAMENTO MANUAL
  # -> OS SERVICOS ACIONADOS ESTAO FICANDO COM atdfnlflg = "N"
  # -> Lucas Scheid - DIA 24/10/2006

  define lr_parametro record
         atdsrvnum    like datmservico.atdsrvnum,
         atdsrvano    like datmservico.atdsrvano,
         atdfnlflg    like datmservico.atdfnlflg,
         modulo       char(10),
         funcao       char(50),
         n_cursor     char(15), # -> NOME DO CURSOR
         funmat       char(06),
         tipo         char(01) # -> A-ANTES   D-DEPOIS
  end record

  define l_msg        char(500),
         l_etapa      like datmsrvacp.atdetpcod,
         l_atdfnlflg  like datmservico.atdfnlflg,
         l_acnsttflg  like datmservico.acnsttflg,
         l_atdlibflg  like datmservico.atdlibflg

  if m_cts40g12_prep is null or
     m_cts40g12_prep <> true then
     call cts40g12_prepare()
  end if

  let l_msg       = null
  let l_etapa     = null
  let l_atdfnlflg = null
  let l_acnsttflg = null
  let l_atdlibflg = null

  # -> BUSCA A ULTIMA ETAPA DO SERVICO
  let l_etapa = cts10g04_ultima_etapa(lr_parametro.atdsrvnum,
                                      lr_parametro.atdsrvano)

  # -> BUSCA O ATDFNLFLG
  open c_cts40g12_007 using lr_parametro.atdsrvnum,
                          lr_parametro.atdsrvano
  fetch c_cts40g12_007 into l_atdfnlflg,
                          l_acnsttflg,
                          l_atdlibflg
  close c_cts40g12_007

  if lr_parametro.tipo = "A" then
     let l_msg = "VAI ATUALIZAR A DATMSERVICO!! "
  else
     let l_msg = "DATMSERVICO ATUALIZADA!! "
  end if

  # -> MONTA A MENSAGEM PARA JOGAR NO LOG
  let l_msg = l_msg clipped,
              "SERVICO: ", lr_parametro.atdsrvnum using "<<<<<<<<<&", "-",
                           lr_parametro.atdsrvano using "&&",
              "|FLAG(PARAMETRO): ", lr_parametro.atdfnlflg,
              "|FLAG(ATUAL): ", l_atdfnlflg,
              "|ETAPA: ", l_etapa using "<<<<&",
              "|ACNSTTFLG: ", l_acnsttflg,
              "|ATDLIBFLG: ", l_atdlibflg,
              "|MODULO: ",     lr_parametro.modulo   clipped,
              "|FUNCAO: ",     lr_parametro.funcao   clipped,
              "|NOME CURSOR: ",lr_parametro.n_cursor clipped,
              "|MATRICULA: ",  lr_parametro.funmat   clipped

   call errorlog(l_msg)

end function

#-----------------------------------------------------------------------------#
function cts40g12_ver_indexacao(lr_param)
#-----------------------------------------------------------------------------#

   define lr_param       record
          lclltt         like datmlcl.lclltt,
          lcllgt         like datmlcl.lcllgt,
          atdsrvnum      like datmlcl.atdsrvnum,
          atdsrvano      like datmlcl.atdsrvano,
          atdsrvorg      like datmservico.atdsrvorg
   end record

   define lr_cts40g00    record
         resultado    smallint,  # 0 - Ok   1 - Not Found   2 - Erro de acesso
         mensagem     char(100),
         acnlmttmp    like datkatmacnprt.acnlmttmp,
         acntntlmtqtd like datkatmacnprt.acntntlmtqtd,
         netacnflg    like datkatmacnprt.netacnflg,
         atmacnprtcod like datkatmacnprt.atmacnprtcod
   end record

   define lr_cts41g03   record
          resultado     smallint,
          mensagem      char(70),
          gpsacngrpcod  like datkmpacid.gpsacngrpcod,
          mpacidcod     like datkmpacid.mpacidcod
   end record

   define l_aciona      char(1),
          l_c24lclpdrcod  like datmlcl.c24lclpdrcod,
          l_cidnom        like datmlcl.cidnom,
          l_ufdcod        like datmlcl.ufdcod

   initialize lr_cts40g00.* to null
   initialize lr_cts41g03.* to null
   let l_aciona = true

   # Coordenadas nulas
   if lr_param.lclltt is null or lr_param.lclltt = 0 or
      lr_param.lcllgt is null or lr_param.lcllgt = 0 then
      let l_aciona = false
   else
      let l_c24lclpdrcod = null
      let l_cidnom = null
      let l_ufdcod = null
   
      open c_cts40g12_008 using lr_param.atdsrvnum, lr_param.atdsrvano
      fetch c_cts40g12_008 into l_cidnom, l_ufdcod, l_c24lclpdrcod
      close c_cts40g12_008
   
      call cts40g00_obter_parametro(lr_param.atdsrvorg)
          returning lr_cts40g00.*
   
      call cts41g03_tipo_acion_cidade(l_cidnom, l_ufdcod,
                                      lr_cts40g00.atmacnprtcod,
                                      lr_param.atdsrvorg)
           returning lr_cts41g03.*
   
      if lr_cts41g03.gpsacngrpcod > 0 then ## GPS
         if  l_c24lclpdrcod <> 3  and
             l_c24lclpdrcod <> 4  and # PSI 252891
             l_c24lclpdrcod <> 5  and 
             (not cts40g12_gpsacncid(l_cidnom, l_ufdcod))  # Verifica se o acionamento GPS pode ser realizado pela coordenada da Cidade
             then
                let l_aciona = false
         end if
      end if
   end if

   return l_aciona

end function

#-----------------------------------------------------------------------------#
function cts40g12_gpsacncid(lr_param)
#-----------------------------------------------------------------------------#
  define lr_param       record
     cidnom         like datmlcl.cidnom,
     ufdcod         like datmlcl.ufdcod
  end record
   
  define l_ciduf char(50),
         l_codigo integer,
         l_retorno integer
   
  if m_cts40g12_prep is null or
     m_cts40g12_prep <> true then
     call cts40g12_prepare()
  end if

  let l_ciduf = lr_param.ufdcod clipped, '-', lr_param.cidnom
  
  open c_cts40g12_009 using l_ciduf
  fetch c_cts40g12_009 into l_codigo

  if sqlca.sqlcode = 0 then
     let l_retorno = false
  else
     let l_retorno = true
  end if
  
  close c_cts40g12_009
  
  return l_retorno
  
end function

