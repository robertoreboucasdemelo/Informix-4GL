#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: TELEATENDIMENTO - CENTRAL 24 HORAS                         #
# MODULO.........: CTS40G20                                                   #
# ANALISTA RESP..: CARLOS ANTONIO RUIZ                                        #
# PSI/OSF........: 196541 - AGENDAMENTO DE SERVICOS                           #
#                  MODULO AUXILIAR - ACESSOS A TABELA(DATMAGNWEBSRV).         #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 03/02/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 30/10/2008 Amilton, Meta   Psi230669  Incluir atdnum na funcao insere web   #
#-----------------------------------------------------------------------------#
# 10/03/2009 carla Rampazzo  PSI235580  Gravar agendamento do Curso de Direcao#
#                                       Defensiva                             #
#-----------------------------------------------------------------------------#

database porto

  define m_cts40g20_prep smallint

#-----------------------------------------------------------------------------#
function cts40g20_prepare()
#-----------------------------------------------------------------------------#

  define l_sql char(500)

  let l_sql = " select sttweb, ",
                     " abnwebflg, ",
                     " ligasscod, ",
                     " vstagnnum, ",
                     " vstagnstt, ",
                     " orgvstagnnum ",
                " from datmagnwebsrv ",
               " where atdcademp = ? ",
                 " and atdcadmat = ? "

  prepare p_cts40g20_001 from l_sql
  declare c_cts40g20_001 cursor for p_cts40g20_001

  let l_sql = " delete ",
                " from datmagnwebsrv ",
               " where atdcademp = ? ",
                 " and atdcadmat = ? "

  prepare p_cts40g20_002 from l_sql

  let l_sql = " insert ",
                " into datmagnwebsrv ",
                    " (atdcademp, ",
                     " atdcadmat, ",
                     " succod, ",
                     " ramcod, ",
                     " aplnumdig, ",
                     " itmnumdig, ",
                     " prporgpcp, ",
                     " prpnumpcp, ",
                     " c24solnom, ",
                     " c24soltipcod, ",
                     " corsus, ",
                     " vstagnnum, ",
                     " lignum, ",
                     " corlignum, ",
                     " corligano, ",
                     " sttweb, ",
                     " ligasscod, ",
                     " ligorgcod, ",
                     " abnwebflg, ",
                     " empcod, ",
                     " funmat, ",
                     " funnom, ",
                     " cornom, ",
                     " vstagnstt, ",
                     " corasshstflg, ",
                     " orgvstagnnum, ",
                     " atdnum ) ",
              " values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ",
                     " ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?) "

  prepare p_cts40g20_003 from l_sql

  let l_sql = " insert ",
                " into dacrligagnvst ",
                    " (corlignum, ",
                     " corligitmseq, ",
                     " vstagnnum, ",
                     " vstagnstt, ",
                     " corligano) ",
              " values(?, ?, ?, ?, ?) "

  prepare p_cts40g20_004 from l_sql

  let l_sql = " update dacrligagnvst ",
                " set (vstagnstt) = (?) ",
               " where corlignum = ? ",
                 " and corligano = ? ",
                 " and corligitmseq = ? ",
                 " and vstagnnum = ? "

  prepare p_cts40g20_005 from l_sql

  let l_sql = " insert ",
                " into datrligagn ",
                    " (lignum, ",
                     " vstagnnum, ",
                     " vstagnstt) ",
              " values(?, ?, ?) "

  prepare p_cts40g20_006 from l_sql

  let l_sql = " update datrligagn ",
                " set (vstagnstt) = (?) ",
               " where lignum = ? ",
                 " and vstagnnum = ? "

  prepare p_cts40g20_007 from l_sql

  let l_sql = " update datmligacao ",
                " set (c24astcod) = (?) ",
               " where lignum = ? "

  prepare p_cts40g20_008 from l_sql

  let l_sql = " select max(lignum) ",
                " from datrligagn ",
               " where vstagnnum = ? "

  prepare p_cts40g20_009 from l_sql
  declare c_cts40g20_002 cursor for p_cts40g20_009

  let l_sql = " select max(corlignum) ",
                " from dacrligagnvst ",
               " where vstagnnum = ? ",
                 " and corligano = ? "

  prepare p_cts40g20_010 from l_sql
  declare c_cts40g20_003 cursor for p_cts40g20_010


  ---> Agendamento do Curso Direcao Defensiva (Segurado)
  let l_sql = " insert into datrdrscrsagdlig (lignum, ",
                                            " drscrsagdcod, ",
                                            " agdligrelstt) ",
                                 " values(?, ?, ?) "
  prepare p_cts40g20_011 from l_sql


  ---> Alteracao do Status do Curso Direcao Defensiva (Segurado)
  let l_sql = " update datrdrscrsagdlig ",
                 " set (agdligrelstt) = (?) ",
               " where lignum         = ? ",
                 " and drscrsagdcod   = ? "
  prepare p_cts40g20_012 from l_sql


  ---> Curso Direcao Defensiva (Segurado)
  let l_sql = " select max(lignum) ",
                " from datrdrscrsagdlig ",
               " where drscrsagdcod = ? "
  prepare p_cts40g20_013 from l_sql
  declare c_cts40g20_004 cursor for p_cts40g20_013


  ---> Agendamento do Curso Direcao Defensiva (Corretor)
  let l_sql = " insert into dacrdrscrsagdlig (corlignum, ",
                                            " corligano, ",
                                            " corligitmseq, ",
                                            " drscrsagdcod, ",
                                            " agdligrelstt) ",
                                    " values(?,?,?,?,?) "
  prepare p_cts40g20_014 from l_sql


  ---> Alteracao do Status do Curso Direcao Defensiva (Corretor)
  let l_sql = " update dacrdrscrsagdlig ",
                 " set (agdligrelstt)    = (?) ",
               " where corlignum    = ? ",
                 " and corligano    = ? ",
                 " and corligitmseq = ? ",
                 " and drscrsagdcod = ? "
  prepare p_cts40g20_015 from l_sql


  ---> Curso Direcao Defensiva (Corretor)
  let l_sql = " select max(corlignum) ",
                " from dacrdrscrsagdlig ",
               " where drscrsagdcod = ? ",
                 " and corligano    = ? "
  prepare p_cts40g20_016 from l_sql
  declare c_cts40g20_005 cursor for p_cts40g20_016


  let m_cts40g20_prep = true

end function

#-----------------------------------------------------------------------------#
function cts40g20_apaga_web(lr_parametro)
#-----------------------------------------------------------------------------#

  define lr_parametro record
         atdcademp    like datmagnwebsrv.atdcademp, # ---> EMPRESA
         atdcadmat    like datmagnwebsrv.atdcadmat  # ---> MATRICULA
  end record

  if m_cts40g20_prep is null or
     m_cts40g20_prep <> true then
     call cts40g20_prepare()
  end if

  whenever error continue
  execute p_cts40g20_002 using lr_parametro.atdcademp, lr_parametro.atdcadmat
  whenever error stop

  if sqlca.sqlcode <> 0 then
     error "Erro DELETE p_cts40g20_002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
     error "cts40g20_apaga_web() / ", lr_parametro.atdcademp, "/",
                                      lr_parametro.atdcadmat sleep 3
     error "FAVOR AVISAR A INFORMATICA !" sleep 3
  end if

end function

#-----------------------------------------------------------------------------#
function cts40g20_pesq_web(lr_parametro)
#-----------------------------------------------------------------------------#

  define lr_parametro record
         atdcademp    like datmagnwebsrv.atdcademp, # ---> EMPRESA
         atdcadmat    like datmagnwebsrv.atdcadmat  # ---> MATRICULA
  end record

  define l_sttweb       like datmagnwebsrv.sttweb,
         l_abnwebflg    like datmagnwebsrv.abnwebflg,
         l_ligasscod    like datmagnwebsrv.ligasscod,
         l_vstagnnum    like datmagnwebsrv.vstagnnum,
         l_vstagnstt    like datmagnwebsrv.vstagnstt,
         l_orgvstagnnum like datmagnwebsrv.orgvstagnnum,
         l_status     smallint # 0 --> ENCONTROU REGISTRO
                               # 1 --> NAO ENCONTROU REGISTRO
                               # 3 --> ERRO DE ACESSO AO BD

  if m_cts40g20_prep is null or
     m_cts40g20_prep <> true then
     call cts40g20_prepare()
  end if

  let l_sttweb       = null
  let l_abnwebflg    = null
  let l_ligasscod    = null
  let l_vstagnnum    = null
  let l_vstagnstt    = null
  let l_orgvstagnnum = null

  let l_status       = 0

  open c_cts40g20_001 using lr_parametro.atdcademp, lr_parametro.atdcadmat
  whenever error continue
  fetch c_cts40g20_001 into l_sttweb,
                          l_abnwebflg,
                          l_ligasscod,
                          l_vstagnnum,
                          l_vstagnstt,
                          l_orgvstagnnum
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_status       = 1
        let l_sttweb       = null
        let l_abnwebflg    = null
        let l_ligasscod    = null
        let l_vstagnnum    = null
        let l_vstagnstt    = null
        let l_orgvstagnnum = null
     else
        error "Erro SELECT c_cts40g20_001 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
        error "cts40g20_pesq_web() / ", lr_parametro.atdcademp, "/",
                                        lr_parametro.atdcadmat sleep 3
        error "FAVOR AVISAR A INFORMATICA !" sleep 3
        let l_status = 2
     end if
  end if

  close c_cts40g20_001

  return l_status,
         l_sttweb,
         l_abnwebflg,
         l_ligasscod,
         l_vstagnnum,
         l_vstagnstt,
         l_orgvstagnnum

end function

#-----------------------------------------------------------------------------#
function cts40g20_insere_web(lr_parametro)
#-----------------------------------------------------------------------------#

  define lr_parametro record
         atdcademp    like datmagnwebsrv.atdcademp,
         atdcadmat    like datmagnwebsrv.atdcadmat,
         succod       like datmagnwebsrv.succod,
         ramcod       like datmagnwebsrv.ramcod,
         aplnumdig    like datmagnwebsrv.aplnumdig,
         itmnumdig    like datmagnwebsrv.itmnumdig,
         prporgpcp    like datmagnwebsrv.prporgpcp,
         prpnumpcp    like datmagnwebsrv.prpnumpcp,
         c24solnom    like datmagnwebsrv.c24solnom,
         c24soltipcod like datmagnwebsrv.c24soltipcod,
         corsus       like datmagnwebsrv.corsus,
         vstagnnum    like datmagnwebsrv.vstagnnum,
         lignum       like datmagnwebsrv.lignum,
         corlignum    like datmagnwebsrv.corlignum,
         corligano    like datmagnwebsrv.corligano,
         sttweb       like datmagnwebsrv.sttweb,
         ligasscod    like datmagnwebsrv.ligasscod,
         ligorgcod    like datmagnwebsrv.ligorgcod,
         abnwebflg    like datmagnwebsrv.abnwebflg,
         empcod       like datmagnwebsrv.empcod,
         funmat       like datmagnwebsrv.funmat,
         funnom       like datmagnwebsrv.funnom,
         cornom       like datmagnwebsrv.cornom,
         vstagnstt    like datmagnwebsrv.vstagnstt,
         corasshstflg like datmagnwebsrv.corasshstflg,
         orgvstagnnum like datmagnwebsrv.orgvstagnnum,
         atdnum       like datmatd6523.atdnum
  end record

  if m_cts40g20_prep is null or
     m_cts40g20_prep <> true then
     call cts40g20_prepare()
  end if

  whenever error continue
  execute p_cts40g20_003 using lr_parametro.atdcademp,
                             lr_parametro.atdcadmat,
                             lr_parametro.succod,
                             lr_parametro.ramcod,
                             lr_parametro.aplnumdig,
                             lr_parametro.itmnumdig,
                             lr_parametro.prporgpcp,
                             lr_parametro.prpnumpcp,
                             lr_parametro.c24solnom,
                             lr_parametro.c24soltipcod,
                             lr_parametro.corsus,
                             lr_parametro.vstagnnum,
                             lr_parametro.lignum,
                             lr_parametro.corlignum,
                             lr_parametro.corligano,
                             lr_parametro.sttweb,
                             lr_parametro.ligasscod,
                             lr_parametro.ligorgcod,
                             lr_parametro.abnwebflg,
                             lr_parametro.empcod,
                             lr_parametro.funmat,
                             lr_parametro.funnom,
                             lr_parametro.cornom,
                             lr_parametro.vstagnstt,
                             lr_parametro.corasshstflg,
                             lr_parametro.orgvstagnnum,
                             lr_parametro.atdnum
  whenever error stop

  if sqlca.sqlcode <> 0 then
     error "Erro INSERT p_cts40g20_003 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
     error "cts40g20_insere_web() / ", lr_parametro.atdcademp, "/",
                                       lr_parametro.atdcadmat sleep 3
     error "FAVOR AVISAR A INFORMATICA !" sleep 3
  end if

end function

#-----------------------------------------------------------------------------#
function cts40g20_ret_codassu(lr_parametro)
#-----------------------------------------------------------------------------#

  define lr_parametro record
         atendimento  char(01),  # --> "C" = ATD. CORRETOR   "S" = ATD. SEGURADO
         ligorgcod    like datmagnwebsrv.ligorgcod,
         ligasscod    like datmagnwebsrv.ligasscod,
         tp_agd       smallint ---> Tipo Agendamento: 1- Curso Direcao Defensiva
                               --->                   2- Demais Agendamentos
  end record

  define l_c24astcod    like datmligacao.c24astcod

  let l_c24astcod = null

  if lr_parametro.atendimento = "C" then # ---> ATD. CORRETOR

     if lr_parametro.ligorgcod = 1  then # ---> CENTRAL 24 HORAS

        if lr_parametro.tp_agd = 2 then ---> Demais Agendamentos

           case lr_parametro.ligasscod
              when 1
                 let l_c24astcod = "289"  # ---> AGENDAR
              when 2
                 let l_c24astcod = "367"  # ---> CONSULTAR
              when 3
                 let l_c24astcod = "290"  # ---> CANCELAR
              when 4
                 let l_c24astcod = "368"  # ---> ALTERAR
           end case
        end if

        if lr_parametro.tp_agd = 1 then ---> Curso Direcao Defensiva

           case lr_parametro.ligasscod
              when 1
                 let l_c24astcod = "498"  # ---> AGENDAR
              when 2
                 let l_c24astcod = "499"  # ---> CONSULTAR
              when 3
                 let l_c24astcod = "501"  # ---> CANCELAR
              when 4
                 let l_c24astcod = "500"  # ---> ALTERAR
           end case
        end if
     end if

     if lr_parametro.ligorgcod = 2  then # ---> TELEPERFORMANCE
        case lr_parametro.ligasscod
           when 1
              let l_c24astcod = "215" # ---> AGENDAR
           when 2
              let l_c24astcod = "369" # ---> CONSULTAR
           when 3
              let l_c24astcod = "216" # ---> CANCELAR
           when 4
              let l_c24astcod = "370" # ---> ALTERAR
        end case
     end if
  end if

  if lr_parametro.atendimento = "S" then # ---> ATD. SEGURADO

     if lr_parametro.tp_agd = 2 then ---> Demais Agendamentos
        case lr_parametro.ligasscod
            when 1
               let l_c24astcod = "D68" # ---> AGENDAR
            when 2
               let l_c24astcod = "D18" # ---> CONSULTAR
            when 3
               let l_c24astcod = "D15" # ---> CANCELAR
            when 4
               let l_c24astcod = "D17" # ---> ALTERAR
         end case
     end if

     if lr_parametro.tp_agd = 1 then ---> Curso Direcao Defensiva
        case lr_parametro.ligasscod
            when 1
               let l_c24astcod = "D00" # ---> AGENDAR
            when 2
               let l_c24astcod = "D10" # ---> CONSULTAR
            when 3
               let l_c24astcod = "D12" # ---> CANCELAR
            when 4
               let l_c24astcod = "D11" # ---> ALTERAR
         end case
     end if
  end if

  return l_c24astcod

end function

#-----------------------------------------------------------------------------#
function cts40g20_grava_agend(lr_parametro)
#-----------------------------------------------------------------------------#

  define lr_parametro record
         atendimento  char(01),  # --> "C" = ATD. CORRETOR   "S" = ATD. SEGURADO
         orgvstagnnum like datmagnwebsrv.orgvstagnnum,
         corlignum    like dacrligagnvst.corlignum,
         corligitmseq like dacrligagnvst.corligitmseq,
         vstagnnum    like dacrligagnvst.vstagnnum,
         vstagnstt    like dacrligagnvst.vstagnstt,
         corligano    like dacrligagnvst.corligano,
         lignum       like datrligagn.lignum
  end record

  define l_status     smallint, # --> 0 = OK  2 = ERRO ACESSO BD
         l_lignum     like datrligagn.lignum,
         l_corlignum  like dacrligagnvst.corlignum,
         l_corligano  like dacrligagnvst.corligano

  if m_cts40g20_prep is null or
     m_cts40g20_prep <> true then
     call cts40g20_prepare()
  end if

  let l_status = 0

  # ---> ATENDIMENTO AO CORRETOR
  if lr_parametro.atendimento = "C" then
     if lr_parametro.vstagnnum is not null then
        if lr_parametro.vstagnstt is null then
           let lr_parametro.vstagnstt = "A"  # agendado e cancelado
        end if
        whenever error continue
        execute p_cts40g20_004 using lr_parametro.corlignum,
                                   lr_parametro.corligitmseq,
                                   lr_parametro.vstagnnum,
                                   lr_parametro.vstagnstt,
                                   lr_parametro.corligano
        whenever error stop
        if sqlca.sqlcode <> 0 then
           error "Erro INSERT p_cts40g20_004 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
           error "cts40g20_grava_agend() / ", lr_parametro.corlignum, "/",
                                              lr_parametro.corligano, "/",
                                              lr_parametro.corligitmseq, "/",
                                              lr_parametro.vstagnnum sleep 3
           error "FAVOR AVISAR A INFORMATICA !" sleep 3
           let l_status = 2
        end if
     end if

     if lr_parametro.orgvstagnnum <> 0 then

        # ---> ATUALIZA O STATUS DO AGENDAMENTO P/ "C"
        let l_corlignum = null

        open c_cts40g20_003 using lr_parametro.orgvstagnnum,
                                lr_parametro.corligano
        fetch c_cts40g20_003 into l_corlignum
        close c_cts40g20_003

        if l_corlignum is not null then

           # CORLIGITMSEQ = 1 (SEQUENCIA DA LIGACAO QUANDO GEROU O AGENDAMENTO)
           whenever error continue
           execute p_cts40g20_005 using "C",
                                      l_corlignum,
                                      lr_parametro.corligano,
                                      "1",         #lr_parametro.corligitmseq,
                                      lr_parametro.orgvstagnnum
           whenever error stop
           if sqlca.sqlcode <> 0 then
              error "Erro UPDATE p_cts40g20_005 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
              error "cts40g20_grava_agend() / ", l_corlignum, "/",
                                             lr_parametro.corligano, "/",
                                             lr_parametro.corligitmseq, "/",
                                             lr_parametro.orgvstagnnum sleep 3
              error "FAVOR AVISAR A INFORMATICA !" sleep 3
              let l_status = 2
           end if
        end if
     end if
  end if

  if lr_parametro.atendimento = "S" then # --> ATENDIMENTO AO SEGURADO
     if lr_parametro.vstagnnum is not null then

        if lr_parametro.vstagnstt is null then
           let lr_parametro.vstagnstt = "A"  # AGENDADO E CANCELADO
        end if

        whenever error continue
        execute p_cts40g20_006 using lr_parametro.lignum,
                                   lr_parametro.vstagnnum,
                                   lr_parametro.vstagnstt
        whenever error stop
        if sqlca.sqlcode <> 0 then
           error "Erro INSERT p_cts40g20_006 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
           error "cts40g20_grava_agend() / ",  lr_parametro.lignum, "/",
                                               lr_parametro.vstagnnum sleep 3
           error "FAVOR AVISAR A INFORMATICA !" sleep 3
           let l_status = 2
        end if
     end if

     if lr_parametro.orgvstagnnum <> 0 then
        # ---> ATUALIZA O STATUS DO AGENDAMENTO P/ "C"
        let l_lignum = null

        open c_cts40g20_002 using lr_parametro.orgvstagnnum
        fetch c_cts40g20_002 into l_lignum
        close c_cts40g20_002

        if l_lignum is not null then
           whenever error continue
           execute p_cts40g20_007 using "C",
                                      l_lignum,
                                      lr_parametro.orgvstagnnum
           whenever error stop
           if sqlca.sqlcode <> 0 then
              error "Erro UPDATE p_cts40g20_007 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
              error "cts40g20_grava_agend() / ", l_lignum, "/",
                                        lr_parametro.orgvstagnnum sleep 3
              error "FAVOR AVISAR A INFORMATICA !" sleep 3
              let l_status = 2
           end if
        end if
     end if
  end if

  return l_status

end function


#------------------------------------------------------------------------------#
function cts40g20_grava_dir_def(lr_parametro)
#------------------------------------------------------------------------------#
---> Agendamento do Curso de Direcao defensiva

   define lr_parametro   record
          atendimento    char(01)  --> "C"= ATD. CORRETOR   "S"= ATD. SEGURADO
         ,orgvstagnnum   like datmagnwebsrv.orgvstagnnum
         ,corlignum      like dacrdrscrsagdlig.corlignum
         ,corligitmseq   like dacrdrscrsagdlig.corligitmseq
         ,drscrsagdcod   like dacrdrscrsagdlig.drscrsagdcod   ---> vstagnnum
         ,agdligrelstt   like datrdrscrsagdlig.agdligrelstt   ---> vstagnstt
         ,corligano      like dacrdrscrsagdlig.corligano
         ,lignum         like datrdrscrsagdlig.lignum
   end record

   define l_status       smallint # --> 0 = OK  2 = ERRO ACESSO BD
         ,l_lignum       like datrdrscrsagdlig.lignum
         ,l_corlignum    like dacrdrscrsagdlig.corlignum
         ,l_corligano    like dacrdrscrsagdlig.corligano

   if m_cts40g20_prep is null or
      m_cts40g20_prep <> true then
      call cts40g20_prepare()
   end if

   let l_status = 0

   ---> ATENDIMENTO AO CORRETOR

   if lr_parametro.atendimento = "C" then

      if lr_parametro.drscrsagdcod is not null then

         if lr_parametro.agdligrelstt is null then
            let lr_parametro.agdligrelstt = "A"  ---> Agendado
         end if

         whenever error continue
         execute p_cts40g20_014 using lr_parametro.corlignum
                                   ,lr_parametro.corligano
                                   ,lr_parametro.corligitmseq
                                   ,lr_parametro.drscrsagdcod
                                   ,lr_parametro.agdligrelstt
         whenever error stop
         if sqlca.sqlcode <> 0 then
            error "Erro INSERT p_cts40g20_014 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
            error "cts40g20_grava_dir_def() / ", lr_parametro.corlignum, "/",
                                               lr_parametro.corligano, "/",
                                               lr_parametro.corligitmseq, "/",
                                               lr_parametro.drscrsagdcod sleep 3
            error "FAVOR AVISAR A INFORMATICA !" sleep 3
            let l_status = 2
         end if
      end if

      if lr_parametro.orgvstagnnum <> 0 then
         # ---> ATUALIZA O STATUS DO AGENDAMENTO P/ "C"
         let l_corlignum = null

         open c_cts40g20_005 using lr_parametro.orgvstagnnum
                                ,lr_parametro.corligano
         fetch c_cts40g20_005 into l_corlignum
         close c_cts40g20_005

         if l_corlignum is not null then

            # CORLIGITMSEQ = 1 (SEQUENCIA DA LIGACAO QUANDO GEROU O AGENDAMENTO)
            whenever error continue
            execute p_cts40g20_015 using "C",
                                       l_corlignum,
                                       lr_parametro.corligano,
                                       "1",         #lr_parametro.corligitmseq,
                                       lr_parametro.orgvstagnnum
            whenever error stop
            if sqlca.sqlcode <> 0 then
               error "Erro UPDATE p_cts40g20_015 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
               error "cts40g20_grava_dir_def() / ", l_corlignum, "/",
                                              lr_parametro.corligano, "/",
                                              lr_parametro.corligitmseq, "/",
                                              lr_parametro.orgvstagnnum sleep 3
               error "FAVOR AVISAR A INFORMATICA !" sleep 3
               let l_status = 2
            end if
         end if
      end if
   end if

   if lr_parametro.atendimento = "S" then # --> ATENDIMENTO AO SEGURADO

      if lr_parametro.drscrsagdcod is not null then

         if lr_parametro.agdligrelstt is null then
            let lr_parametro.agdligrelstt = "A"  ---> Agendado
         end if

         whenever error continue
         execute p_cts40g20_011 using lr_parametro.lignum,
                                    lr_parametro.drscrsagdcod,
                                    lr_parametro.agdligrelstt
         whenever error stop
         if sqlca.sqlcode <> 0 then
            error "Erro INSERT p_cts40g20_011 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
            error "cts40g20_grava_dir_def() / ",  lr_parametro.lignum, "/",
                                                lr_parametro.drscrsagdcod sleep 3
            error "FAVOR AVISAR A INFORMATICA !" sleep 3
            let l_status = 2
         end if
      end if
      if lr_parametro.orgvstagnnum <> 0 then
         # ---> ATUALIZA O STATUS DO AGENDAMENTO P/ "C"
         let l_lignum = null

         open c_cts40g20_004 using lr_parametro.orgvstagnnum
         fetch c_cts40g20_004 into l_lignum
         close c_cts40g20_004
         if l_lignum is not null then
            whenever error continue
            execute p_cts40g20_012 using "C",
                                       l_lignum,
                                       lr_parametro.orgvstagnnum
            whenever error stop
            if sqlca.sqlcode <> 0 then
               error "Erro UPDATE p_cts40g20_012 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
               error "cts40g20_grava_dir_def() / ", l_lignum, "/",
                                         lr_parametro.orgvstagnnum sleep 3
               error "FAVOR AVISAR A INFORMATICA !" sleep 3
               let l_status = 2
            end if
         end if
      end if
   end if

   return l_status

end function


#-----------------------------------------------------------------------------#
function cts40g20_atlz_asslig(lr_parametro)
#-----------------------------------------------------------------------------#

  define lr_parametro record
         c24astcod    like datmligacao.c24astcod,
         lignum       like datmligacao.lignum
  end record

  if m_cts40g20_prep is null or
     m_cts40g20_prep <> true then
     call cts40g20_prepare()
  end if

  whenever error continue
  execute p_cts40g20_008 using lr_parametro.c24astcod, lr_parametro.lignum
  whenever error stop

  if sqlca.sqlcode <> 0 then
     error "Erro UPDATE p_cts40g20_008 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 3
     error "cts40g20_atlz_asslig() / ", lr_parametro.lignum, "/",
                                        lr_parametro.c24astcod sleep 3
     error "FAVOR AVISAR A INFORMATICA !" sleep 3
  end if

end function
