#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
#.............................................................................#
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: BDBSR105                                                   #
# ANALISTA RESP..: RAJI DUENHAS JAHCHAN                                       #
# PSI/OSF........: 196562                                                     #
#                  ACOMPANHAMENTO DO TEMPO DE ATENDIMENTO DOS SOCORRISTAS.    #
#.............................................................................#
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 02/12/2005                                                 #
#.............................................................................#
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 26/04/07   M Federicce     PSI 207373 Inclusao das colunas BAIRRO NO REC,   #
#                                       BAIRRO NO INI, BAIRRO NO FIM e DIST.  #
#                                       ENTRE FIM-QTI                         #
#-----------------------------------------------------------------------------#
# 10/05/2011 Celso Yamahaki             Inclusao das colunas SUC, RAMO, APL,  #
#                                       ITEM, SEGURADO, COD MARCA, MARCA VEIC,#
#                                       PLACA, ANO MOD, COD ASSUNTO, DESC AS- #
#                                       SUNTO e Correcao nos parametros da co-#
#                                       luna PREVISAO DESCRICAO               #
#-----------------------------------------------------------------------------#
# 29/05/2011 Celso Yamahaki             Correcao nos dados trazidos referentes#
#                                       ao veiculo, marca                     #
#-----------------------------------------------------------------------------#
# 09/06/2011 Celso Yamahaki             Adicionado condicao ao IF dos botoes. #
#                                       Nao imprimir quando status = 4        #
#                                       (botao fora de ordem)                 #
#-----------------------------------------------------------------------------#

database porto

  define m_path         char(100),
         m_desc_tipo    char(10),
         m_carga_array  smallint,
         m_tipo_proce   char(4),
         m_path_txt     char(100)


  define ma_datkfxolcl array [7000] of record
         c24fxolcldes  like datkfxolcl.c24fxolcldes
        ,lclltt        like datkfxolcl.lclltt
        ,lcllgt        like datkfxolcl.lcllgt
  end record

main


  call fun_dba_abre_banco("GUINCHOGPS")
  
  # ---> OBTER O PARAMETRO PARA SABER O TIPO DE PROCESSAMENTO(AUTO OU RE)
  let m_tipo_proce = arg_val(1)

  # ---> VERIFICA SE INFORMOU O PARAMETRO
  if m_tipo_proce is null or
     m_tipo_proce = " " then
     display "Faltou informar o tipo de processamento: AUTO ou RE"
     display "O programa sera finalizado !"
     exit program(1)
  end if  

  call bdbsr105_busca_path()
  
  call bdbsr105_prepare()

  initialize ma_datkfxolcl to null

  call bdbsr105_carga_local_fixo()

  call cts40g03_exibe_info("I","BDBSR105")

  set isolation to dirty read

  call bdbsr105()

  call cts40g03_exibe_info("F","BDBSR105")
  
end main

#-------------------------#
function bdbsr105_prepare()
#-------------------------#

  define l_sql char(1000)

  let l_sql = " select acn.atdsrvnum, ",
                     " acn.atdsrvano, ",
                     " acn.srrcoddig, ",
                     " acn.atdetphor, ",
                     " acn.atdetpdat, ",
                     " acn.pstcoddig, ",
                     " acn.atdsrvseq ",
                " from datmsrvacp acn ",
               " where atdetpcod = ? ",
                 " and acn.socvclcod is not null ",
                 " and acn.atdetpdat = ? ",
                 " and atdsrvseq = (select max(atdsrvseq) ",
                                    " from datmsrvacp ",
                                   " where atdsrvnum = acn.atdsrvnum ",
                                     " and atdsrvano = acn.atdsrvano) ",
               " order by 5, 4 "

  prepare pbdbsr105001 from l_sql
  declare cbdbsr105001 cursor for pbdbsr105001

  let l_sql = " select srrltt,       ",
              "        srrlgt,       ",
              "        atdprvdat,    ",
              "        atdsrvorg,    ",
              "        socvclcod,    ",
              "        atddat, 	     ",
              "        atdhor, 	     ",
              "        atddatprg,    ",
              "        atdhorprg,    ",
              "        ciaempcod,    ",
              "        vclcoddig,    ", # CODIGO MARCA VEICULO
              "        replace(replace(replace(vcldes, chr(13), ''), chr(10), ''), chr(09), ''),  ",
              "        replace(replace(replace(vcllicnum, chr(13), ''), chr(10), ''), chr(09), ''),  ",
              "        vclanomdl,    ", # ANO MODELO VEICULO
              "        replace(replace(replace(nom, chr(13), ''), chr(10), ''), chr(09), '')  ",
              "   from datmservico   ",
              "  where atdsrvnum = ? ",
              "    and atdsrvano = ? ",
              "    and atdprscod = ? ",
              "    and srrcoddig = ? "

  prepare pbdbsr105002 from l_sql
  declare cbdbsr105002 cursor for pbdbsr105002

  let l_sql = " select lclltt, ",
                     " lcllgt, ",
                     " ufdcod, ",
                     " replace(replace(replace(cidnom, chr(13), ''), chr(10), ''), chr(09), ''),  ",
                     " replace(replace(replace(brrnom, chr(13), ''), chr(10), ''), chr(09), '')  ",
                " from datmlcl ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? ",
                 " and c24endtip = 1 "

  prepare pbdbsr105003 from l_sql
  declare cbdbsr105003 cursor for pbdbsr105003

  let l_sql = " select atdetphor, ",
                     " atdetpdat ",
                " from datmsrvacp lib ",
               " where lib.atdsrvnum = ? ",
                 " and lib.atdsrvano = ? ",
                 " and lib.atdetpcod = 1 ",
                 " and lib.atdsrvseq = (select max(atdsrvseq) ",
                                        " from datmsrvacp ",
                                       " where atdsrvnum = ? ",
                                         " and atdsrvano = ? ",
                                         " and atdsrvseq < ? ) "

  prepare pbdbsr105004 from l_sql
  declare cbdbsr105004 cursor for pbdbsr105004

  let l_sql = " select mdtcod, ",
                     " atdvclsgl, ",
                     " socvcltip ",
                " from datkveiculo ",
               " where socvclcod = ? "

  prepare pbdbsr105005 from l_sql
  declare cbdbsr105005 cursor for pbdbsr105005

  let l_sql = " select replace(replace(replace(cpodes, chr(13), ''), chr(10), ''), chr(09), '')  ",
                " from iddkdominio ",
               " where cponom = 'socvcltip' ",
                 " and cpocod = ? "

  prepare pbdbsr105006 from l_sql
  declare cbdbsr105006 cursor for pbdbsr105006

  let l_sql = " select mdtctrcod ",
                " from datkmdt ",
               " where mdtcod = ? "

  prepare pbdbsr105007 from l_sql
  declare cbdbsr105007 cursor for pbdbsr105007

  let l_sql = " select replace(replace(replace(nomgrr, chr(13), ''), chr(10), ''), chr(09), '')  ",
                " from dpaksocor ",
               " where pstcoddig = ? "

  prepare pbdbsr105008 from l_sql
  declare cbdbsr105008 cursor for pbdbsr105008

  let l_sql = " select replace(replace(replace(srrnom, chr(13), ''), chr(10), ''), chr(09), '')  ",
                " from datksrr ",
               " where srrcoddig = ? "

  prepare pbdbsr105009 from l_sql
  declare cbdbsr105009 cursor for pbdbsr105009

  let l_sql = " select msglog.atldat, ",
                     " msglog.atlhor ",
                " from datmmdtsrv msgsrv, ",
                     " datmmdtmsg msg, ",
                     " datmmdtlog msglog ",
               " where msgsrv.atdsrvnum = ? ",
                 " and msgsrv.atdsrvano = ? ",
                 " and msg.mdtmsgnum = msgsrv.mdtmsgnum ",
                 " and msg.mdtcod = ? ",
                 " and msglog.mdtmsgnum = msgsrv.mdtmsgnum ",
                 " and msglog.mdtmsgstt in (0,6) ",
               " order by 1 desc, 2 desc "

  prepare pbdbsr105010 from l_sql
  declare cbdbsr105010 cursor for pbdbsr105010

  let l_sql = " select caddat, ",
                     " cadhor, ",
                     " lclltt, ",
                     " lcllgt, ",
                     " mdtcod, ",
                     " mdtbotprgseq, ",
                     " mdtmvttipcod, ",
                     " mdtmvtstt, ",
                     " replace(replace(replace(brrnom, chr(13), ''), chr(10), ''), chr(09), '') ",
                " from datmmdtmvt ",
               " where atdsrvnum = ? ",
               " and atdsrvano = ? "

  prepare pbdbsr105011 from l_sql
  declare cbdbsr105011 cursor for pbdbsr105011

  let l_sql = " select cidcod ",
                " from glakcid ",
               " where ufdcod = ? ",
                 " and cidnom = ? "

  prepare pbdbsr105012 from l_sql
  declare cbdbsr105012 cursor for pbdbsr105012

  let l_sql = " select cidsedcod ",
                " from datrcidsed ",
               " where cidcod = ? "

  prepare pbdbsr105013 from l_sql
  declare cbdbsr105013 cursor for pbdbsr105013

  let l_sql = " select ufdcod, ",
                     " replace(replace(replace(cidnom, chr(13), ''), chr(10), ''), chr(09), '')  ",
                " from glakcid ",
               " where cidcod = ? "

  prepare pbdbsr105014 from l_sql
  declare cbdbsr105014 cursor for pbdbsr105014

  let l_sql = " select lclltt, ",
                     " lcllgt, ",
                     " ufdcod, ",
                     " replace(replace(replace(cidnom, chr(13), ''), chr(10), ''), chr(09), ''),  ",
                     " replace(replace(replace(brrnom, chr(13), ''), chr(10), ''), chr(09), '')  ",
                " from datmlcl ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? ",
                 " and c24endtip = 2 "

  prepare pbdbsr105015 from l_sql
  declare cbdbsr105015 cursor for pbdbsr105015

  ## Para varrer os locais fixo  - PSI 210838 - ligia
  let l_sql = " select replace(replace(replace(c24fxolcldes, chr(13), ''), chr(10), ''), chr(09), ''),  ",
               "       lclltt, lcllgt from datkfxolcl "
  prepare pbdbsr105016 from l_sql
  declare cbdbsr105016 cursor for pbdbsr105016

  # Busca a Sucursal, Codigo Ramo, Numero da Apolice e Item da Apolice
  let l_sql = "select a.succod,                         ",
              "       a.ramcod,                         ",
              "       a.aplnumdig,                      ",
              "       a.itmnumdig                       ",
              "  from datrligapol a                     ",
              " where a.lignum = (select MIN(lignum)    ",
              "                     from datmligacao    ",
              "                    where atdsrvnum = ?  ",
              "                      and atdsrvano = ? )"

  prepare pbdbsr105017 from l_sql
  declare cbdbsr105017 cursor for pbdbsr105017

   # Busca o nome do segurado
   let l_sql = "select replace(replace(replace(segnom, chr(13), ''), chr(10), ''), chr(09), '')  ",
               "  from gsakseg ",
               " where segnumdig = (select segnumdig ",
               "                     from abbmdoc    ",
               "                    where succod = ? ",
               "                      and aplnumdig = ? ",
               "                      and itmnumdig = ? ",
               "                      and dctnumseq = ? )"

   prepare pbdbsr105018 from l_sql
   declare cbdbsr105018 cursor for pbdbsr105018

   # Busca a maxima sequencia do documento
   let l_sql = "select MAX(dctnumseq)  ",
               "  from abbmdoc    ",
               " where succod = ? ",
               "   and aplnumdig = ? ",
               "   and itmnumdig = ? "

   prepare pbdbsr105019 from l_sql
   declare cbdbsr105019 cursor for pbdbsr105019

   # Busca a Sucursal, Codigo Ramo, Numero da Apolice e Item da Apolice
   let l_sql = "select a.c24astcod,   ",
               "       replace(replace(replace(b.c24astdes, chr(13), ''), chr(10), ''), chr(09), '')  ",
               "  from datmligacao a, ",
               "       datkassunto b  ",
               " where a.lignum = (select MIN(lignum)    ",
               "                     from datmligacao    ",
               "                    where atdsrvnum = ?  ",
               "                      and atdsrvano = ? )",
               "   and a.c24astcod = b.c24astcod"

   prepare pbdbsr105020 from l_sql
   declare cbdbsr105020 cursor for pbdbsr105020

   # Busca pela marca do Veiculo
   let l_sql = 	"select vclmrccod, ",
                "       replace(replace(replace(vclmrcnom, chr(13), ''), chr(10), ''), chr(09), '')  ",
   		"  from agbkmarca 			  ",
   		" where vclmrccod = (select vclmrccod 	  ",
   		" 		       from agbkveic  	  ",
   		"		      where vclcoddig = ?)"

   prepare pbdbsr105021 from l_sql
   declare cbdbsr105021 cursor for pbdbsr105021
   
   let l_sql = " select atddat, atdhor, atdlibhor  ",
               "   from datmservico                   ",
               "  where atdsrvnum = ?                 ",
               "    and atdsrvano = ?                 "  
   prepare pbdbsr105022 from l_sql  
   declare cbdbsr105022 cursor for pbdbsr105022

end function

#-----------------------------------------#
function bdbsr105_envia_email(lr_parametro)
#-----------------------------------------#

  define lr_parametro record
         data_inicial date,
         data_final   date
  end record

  define l_assunto     char(100),
         l_erro_envio  integer,
         l_comando     char(200)

  # ---> INICIALIZACAO DAS VARIAVEIS
  let l_comando    = null
  let l_erro_envio = null
  let l_assunto    = "Acompanhamento do Tempo de Atendimento - ",
                     m_desc_tipo clipped,
                     " do dia: ",
                     lr_parametro.data_inicial using "dd/mm/yyyy"

  # ---> COMPACTA O ARQUIVO DO RELATORIO
  let l_comando = "gzip -f ", m_path

  run l_comando
  let m_path = m_path clipped, ".gz"

  let l_erro_envio = ctx22g00_envia_email("BDBSR105", l_assunto, m_path)

  if l_erro_envio <> 0 then
     if l_erro_envio <> 99 then
        display "Erro ao enviar email(ctx22g00) - ", m_path
     else
        display "Nao existe email cadastrado para o modulo - BDBSR105"
     end if
  end if

end function


#-------------------------------------------#
function bdbsr105_carga_local_fixo()
#-------------------------------------------#

   define l_i smallint

   let l_i = 1

   open cbdbsr105016
   foreach cbdbsr105016 into ma_datkfxolcl[l_i].c24fxolcldes
                            ,ma_datkfxolcl[l_i].lclltt
                            ,ma_datkfxolcl[l_i].lcllgt
      let l_i = l_i + 1
      if l_i > 7000 then
         display "estouro de array"
      end if
   end foreach
   display "CARREGUEI ", l_i, " REGISTROS NO ARRAY"
   let m_carga_array = true



end function


#----------------------------#
function bdbsr105_busca_path()
#----------------------------#

  define l_dataarq char(8)
  define l_data    date
  
  let l_data = (today - 1 units day)
  display "l_data: ", l_data
  let l_dataarq = extend(l_data, year to year),
                  extend(l_data, month to month),
                  extend(l_data, day to day)
  display "l_dataarq: ", l_dataarq

  # ---> INICIALIZACAO DAS VARIAVEIS
  let m_path = null

  # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE LOG
  let m_path = f_path("DBS","LOG")

  if m_path is null then
     let m_path = "."
  end if

  let m_path = m_path clipped,"/bdbsr105.log"

  call startlog(m_path)

  # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE RELATORIO
  let m_path = f_path("DBS", "RELATO")

  if m_path is null then
     let m_path = "."
  end if
     
  let m_path_txt = m_path clipped, "/BDBSR105", m_tipo_proce clipped, l_dataarq, ".txt"
  let m_path = m_path clipped, "/BDBSR105_", m_tipo_proce clipped, "_", l_dataarq, ".xls"

  display 'm_path: ', m_path clipped
  display 'm_path_txt: ', m_path_txt clipped

end function

#-----------------#
function bdbsr105()
#-----------------#

  define l_data_atual        date,
         l_data_inicio       date,
         l_data_fim          date,
         l_hora_atual        datetime hour to minute,
         l_tipo_botao        like datmmdtmvt.mdtbotprgseq,
         l_cpodes            like iddkdominio.cpodes,
         l_mdtctrcod         like datkmdt.mdtctrcod,
         l_nomgrr            like dpaksocor.nomgrr,
         l_srrnom            like datksrr.srrnom,
         l_dis_soc_srv       decimal(8,4),
         l_dis_rec_soc_srv   decimal(8,4),
         l_dis_ini_soc_srv   decimal(8,4),
         l_dis_fim_soc_srv   decimal(8,4),
         l_dis_fim_soc_qti   decimal(8,4),
         l_dis_soc_metros    integer,
         l_dis_rec_metros    integer,
         l_dis_ini_metros    integer,
         l_dis_fim_metros    integer,
         l_dis_qti_metros    integer,
         l_lidos             integer,
         l_desprezados       integer,
         l_tipo              char(10),
         l_tempo             datetime hour to second,
         l_tempo_zerado      datetime hour to second,
         l_prev_segundo      datetime hour to second,
         l_prev_intervalo    interval hour to second,
         l_tmp_liberacao     interval hour(06) to second,
         l_tmp_acionamento   interval hour(06) to second,
         l_tmp_transmissao   interval hour(06) to second,
         l_tmp_qrurec        interval hour(06) to second,
         l_tmp_qruini        interval hour(06) to second,
         l_tmp_espseg        interval hour(06) to second,
         l_tmp_qrufim        interval hour(06) to second,
         l_tmp_totsrv        interval hour(06) to second,
         l_aux_char          char(19),
         l_aux_final         char(19),
         l_dtahor_iniprev    char(19),
         l_resultado         char(08),
         l_aux_datetime      datetime year to second,
         l_tmp_difprev       interval hour(06) to second,
         l_tmp_liberacao_c   char(20),
         l_tmp_acionamento_c char(20),
         l_tmp_transmissao_c char(20),
         l_tmp_qrurec_c      char(20),
         l_tmp_qruini_c      char(20),
         l_tmp_espseg_c      char(20),
         l_tmp_qrufim_c      char(20),
         l_tmp_totsrv_c      char(20),
         l_tmp_difprev_c     char(20),
         l_tipo_proce        char(04),
         l_etapa             smallint,
         l_cidcod            like glakcid.cidcod,
         l_ufdcod_sede       like datmlcl.ufdcod,
         l_cidnom_sede       like datmlcl.cidnom

  define lr_acompa  record
         atdsrvnum  like datmsrvacp.atdsrvnum,
         atdsrvano  like datmsrvacp.atdsrvano,
         srrcoddig  like datmsrvacp.srrcoddig,
         atdetphor  like datmsrvacp.atdetphor,
         atdetpdat  like datmsrvacp.atdetpdat,
         pstcoddig  like datmsrvacp.pstcoddig,
         atdsrvseq  like datmsrvacp.atdsrvseq
  end record

  define lr_auxiliar record
         dh_ini_c    char(19),
         dh_pre_c    char(19),
         dh_ini_d    datetime year to second,
         dh_pre_d    datetime year to second,
         data        char(10),
         hora        char(08)
  end record

  define lr_botao record
        caddat       like datmmdtmvt.caddat,
        cadhor       like datmmdtmvt.cadhor,
        lclltt       like datmmdtmvt.lclltt,
        lcllgt       like datmmdtmvt.lcllgt,
        mdtcod       like datmmdtmvt.mdtcod,
        mdtbotprgseq like datmmdtmvt.mdtbotprgseq,
        mdtmvttipcod like datmmdtmvt.mdtmvttipcod,
        mdtmvtstt    like datmmdtmvt.mdtmvtstt,
        brrnom       like datmmdtmvt.brrnom
  end record

  define lr_servico record
         srrltt     like datmservico.srrltt,
         srrlgt     like datmservico.srrlgt,
         atdprvdat  like datmservico.atdprvdat,
         atdsrvorg  like datmservico.atdsrvorg,
         socvclcod  like datmservico.socvclcod,
         atddat     like datmservico.atddat,
         atdhor     like datmservico.atdhor,
         atddatprg  like datmservico.atddatprg,
         atdhorprg  like datmservico.atdhorprg,
         ciaempcod  like datmservico.ciaempcod,
         vclcoddig  like datmservico.vclcoddig,  # Codigo do Veiculo
         vcldes     like datmservico.vcldes,     # Modelo do Veiculo
         vcllicnum  like datmservico.vcllicnum,  # Placa Veiculo
         vclanomdl  like datmservico.vclanomdl,  # Ano Modelo Veiculo
         nom	    like datmservico.nom,	 # Nome Padrao
         c24astcod  like datmligacao.c24astcod,
         c24astdes  like datkassunto.c24astdes,
         vclmrccod  like agbkmarca.vclmrccod,	 # Codigo da Marca
  	 vclmrcnom  like agbkmarca.vclmrcnom	 # Nome da Marca

  end record
  
  define lr_tmaligldo record
         ligdat      like datmservico.atddat,
         lighorinc   like datmservico.atdhor, #like datmligacao.lighorinc,
         lighorfnl   like datmservico.atdlibhor
  end record

  define lr_segurado record
         succod       like datrligapol.succod,
         ramcod       like datrligapol.ramcod,
         aplnumdig    like datrligapol.aplnumdig,
         itmnumdig    like datrligapol.itmnumdig,
         segnom       like gsakseg.segnom,
         dctnumseq    like abbmdoc.dctnumseq
  end record

  define lr_local    record
         lclltt      like datmlcl.lclltt,
         lcllgt      like datmlcl.lcllgt,
         ufdcod      like datmlcl.ufdcod,
         cidnom      like datmlcl.cidnom,
         brrnom      like datmlcl.brrnom
  end record

  define lr_destino  record
         lclltt      like datmlcl.lclltt,
         lcllgt      like datmlcl.lcllgt,
         ufdcod      like datmlcl.ufdcod,
         cidnom      like datmlcl.cidnom,
         brrnom      like datmlcl.brrnom
  end record

  define lr_liberado record
         atdetphor   like datmsrvacp.atdetphor,
         atdetpdat   like datmsrvacp.atdetpdat
  end record

  define lr_veiculo  record
         mdtcod      like datkveiculo.mdtcod,
         atdvclsgl   like datkveiculo.atdvclsgl,
         socvcltip   like datkveiculo.socvcltip
  end record

  define lr_msglog   record
         atldat      like datmmdtlog.atldat,
         atlhor      like datmmdtlog.atlhor
  end record

  define lr_botao_rec record
         caddat       like datmmdtmvt.caddat,
         cadhor       like datmmdtmvt.cadhor,
         lclltt       like datmmdtmvt.lclltt,
         lcllgt       like datmmdtmvt.lcllgt,
         brrnom       like datmmdtmvt.brrnom,
         coord        char(30),
         endereco     char(100)
  end record

  define lr_botao_ini record
         caddat       like datmmdtmvt.caddat,
         cadhor       like datmmdtmvt.cadhor,
         lclltt       like datmmdtmvt.lclltt,
         lcllgt       like datmmdtmvt.lcllgt,
         brrnom       like datmmdtmvt.brrnom,
         coord        char(30),
         endereco     char(100)
  end record

  define lr_botao_fim record
         caddat       like datmmdtmvt.caddat,
         cadhor       like datmmdtmvt.cadhor,
         lclltt       like datmmdtmvt.lclltt,
         lcllgt       like datmmdtmvt.lcllgt,
         brrnom       like datmmdtmvt.brrnom,
         coord        char(30),
         endereco     char(100)
  end record
  
  define lr_tmaabtldo interval hour(3) to second

  define ws record
        flgfim smallint
  end record

  # ---> INICIALIZACAO DAS VARIAVEIS
  initialize lr_acompa.* to null
  initialize lr_servico.* to null
  initialize lr_local.* to null
  initialize lr_destino.* to null
  initialize lr_liberado.* to null
  initialize lr_veiculo.* to null
  initialize lr_msglog.* to null
  initialize lr_botao_rec.* to null
  initialize lr_botao_ini.* to null
  initialize lr_botao_fim.* to null
  initialize lr_auxiliar.* to null
  initialize ws.* to null
  initialize lr_segurado.* to null
  initialize lr_tmaabtldo to null

  let l_cpodes            = null
  let l_mdtctrcod         = null
  let l_nomgrr            = null
  let l_srrnom            = null
  let l_data_atual        = null
  let l_hora_atual        = null
  let l_data_inicio       = null
  let l_data_fim          = null
  let l_cidcod            = null
  let l_ufdcod_sede       = null
  let l_cidnom_sede       = null
  let l_tipo_botao        = null
  let l_dis_soc_srv       = null
  let l_dis_rec_soc_srv   = null
  let l_dis_ini_soc_srv   = null
  let l_dis_fim_soc_srv   = null
  let l_dis_fim_soc_qti   = null
  let l_tipo              = null
  let m_desc_tipo         = null
  let l_tmp_liberacao     = null
  let l_tmp_acionamento   = null
  let l_tmp_transmissao   = null
  let l_tmp_qrurec        = null
  let l_tmp_qruini        = null
  let l_tmp_espseg        = null
  let l_tmp_qrufim        = null
  let l_tmp_totsrv        = null
  let l_tempo             = null
  let l_tempo_zerado      = "00:00:00"
  let l_prev_segundo      = null
  let l_prev_intervalo    = null
  let l_aux_char          = null
  let l_aux_final         = null
  let l_aux_datetime      = null
  let l_dtahor_iniprev    = null
  let l_resultado         = null
  let l_tmp_difprev       = null
  let l_lidos             = 0
  let l_desprezados       = 0
  let l_dis_soc_metros    = null
  let l_dis_rec_metros    = null
  let l_dis_ini_metros    = null
  let l_dis_fim_metros    = null
  let l_dis_qti_metros    = null
  let l_tmp_liberacao_c   = null
  let l_tmp_acionamento_c = null
  let l_tmp_transmissao_c = null
  let l_tmp_qrurec_c      = null
  let l_tmp_qruini_c      = null
  let l_tmp_espseg_c      = null
  let l_tmp_qrufim_c      = null
  let l_tmp_totsrv_c      = null
  let l_tmp_difprev_c     = null
  let l_tipo_proce        = null
  let l_etapa             = 0

  let l_tipo_proce = m_tipo_proce

  # ---> VERIFICA SE O PARAMETRO E VALIDO
  if l_tipo_proce <> "AUTO" and
     l_tipo_proce <> "RE" then
     display "Parametro invalido: infome AUTO ou RE"
     exit program(1)
  end if

  let m_desc_tipo = l_tipo_proce

  if l_tipo_proce = "AUTO" then
     let l_etapa = 4
  else
     let l_etapa = 3
  end if

  # ---> OBTER A DATA E HORA DO BANCO
  call cts40g03_data_hora_banco(2)
       returning l_data_atual,
                 l_hora_atual

  # ---> DATA DE EXTRACAO DAS INFORMACOES (1 DIA)
  let l_data_inicio = (l_data_atual - 1 units day)
  display " "
  display "******Parametros do Relatório******"
  display "TIPO PROCESSO: ", l_tipo_proce clipped
  display "Data Pesquisa: ", l_data_inicio
  display " "

  start report bdbsr105_relatorio to m_path
  start report bdbsr105_relatorio_txt to m_path_txt

  open cbdbsr105001 using l_etapa
                         ,l_data_inicio

  foreach cbdbsr105001 into lr_acompa.atdsrvnum,
                            lr_acompa.atdsrvano,
                            lr_acompa.srrcoddig,
                            lr_acompa.atdetphor,
                            lr_acompa.atdetpdat,
                            lr_acompa.pstcoddig,
                            lr_acompa.atdsrvseq

     let l_lidos = l_lidos + 1

     open cbdbsr105002 using lr_acompa.atdsrvnum,
                             lr_acompa.atdsrvano,
                             lr_acompa.pstcoddig,
                             lr_acompa.srrcoddig

     whenever error continue
     fetch cbdbsr105002 into lr_servico.srrltt,
                             lr_servico.srrlgt,
                             lr_servico.atdprvdat,
                             lr_servico.atdsrvorg,
                             lr_servico.socvclcod,
                             lr_servico.atddat,
                             lr_servico.atdhor,
                             lr_servico.atddatprg,
                             lr_servico.atdhorprg,
                             lr_servico.ciaempcod,
                             lr_servico.vclcoddig,
                             lr_servico.vcldes,
                             lr_servico.vcllicnum,
                             lr_servico.vclanomdl,
                             lr_servico.nom
     whenever error stop

     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode <> notfound then
           display "Erro SELECT cbdbsr105002 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
           exit program(1)
        end if
     end if

     close cbdbsr105002

     # busca o codigo e a marca do veiculo
     open cbdbsr105021 using lr_servico.vclcoddig
     whenever error continue
     fetch cbdbsr105021 into lr_servico.vclmrccod,
     			       lr_servico.vclmrcnom

     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode <> notfound then
           display "Erro SELECT cbdbsr105021 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
           exit program(1)
        end if
     end if


     whenever error stop
     close  cbdbsr105021

     if lr_servico.atdsrvorg = 10 or    # ---> VISTORIA PREVIA
        lr_servico.atdsrvorg = 15 then  # ---> JIT
        let l_desprezados = l_desprezados + 1
        initialize lr_segurado.* to null
        initialize lr_servico.* to null
        initialize lr_acompa.* to null
        continue foreach
     end if

     if l_tipo_proce = "RE" and
        lr_servico.atdsrvorg <> 9
     and lr_servico.atdsrvorg <> 13 then
        let l_desprezados = l_desprezados + 1
        initialize lr_segurado.* to null
        initialize lr_servico to null
        continue foreach
     end if

     if l_tipo_proce = "AUTO" and
        lr_servico.atdsrvorg = 9
     and lr_servico.atdsrvorg = 13 then
        let l_desprezados = l_desprezados + 1
        initialize lr_segurado.* to null
        initialize lr_servico to null
        continue foreach
     end if

     # ---> SE A PREVISAO ESTIVER NULA, ASSUMIR 20 MINUTOS
     if lr_servico.atdprvdat is null then
        let lr_servico.atdprvdat = "00:20"
     end if

     # ---> BUSCA O TIPO DO SERVICO
     if lr_servico.atddatprg is null and
        lr_servico.atdhorprg is null then
        let l_tipo = "IMEDIATO"
     else
        let l_tipo = "PROGRAMADO"
     end if

     open cbdbsr105003 using lr_acompa.atdsrvnum, lr_acompa.atdsrvano

     whenever error continue
     fetch cbdbsr105003 into lr_local.lclltt,
                             lr_local.lcllgt,
                             lr_local.ufdcod,
                             lr_local.cidnom,
                             lr_local.brrnom
     whenever error stop

     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode <> notfound then
           display "Erro SELECT cbdbsr105003 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
           exit program(1)
        end if
     end if

     close cbdbsr105003

     open cbdbsr105015 using lr_acompa.atdsrvnum, lr_acompa.atdsrvano

     whenever error continue
     fetch cbdbsr105015 into lr_destino.lclltt,
                             lr_destino.lcllgt,
                             lr_destino.ufdcod,
                             lr_destino.cidnom,
                             lr_destino.brrnom
     whenever error stop

     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode <> notfound then
           display "Erro SELECT cbdbsr105015 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
           exit program(1)
        end if
     end if

     close cbdbsr105015

     open cbdbsr105004 using lr_acompa.atdsrvnum,
                             lr_acompa.atdsrvano,
                             lr_acompa.atdsrvnum,
                             lr_acompa.atdsrvano,
                             lr_acompa.atdsrvseq

     whenever error continue
     fetch cbdbsr105004 into lr_liberado.atdetphor, lr_liberado.atdetpdat
     whenever error stop

     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode <> notfound then
           display "Erro SELECT cbdbsr105004 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
           exit program(1)
        end if
     end if

     close cbdbsr105004

     open cbdbsr105005 using lr_servico.socvclcod

     whenever error continue
     fetch cbdbsr105005 into lr_veiculo.mdtcod, lr_veiculo.atdvclsgl, lr_veiculo.socvcltip
     whenever error stop

     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode <> notfound then
           display "Erro SELECT cbdbsr105005 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
           exit program(1)
        end if
     end if

     close cbdbsr105005

     open cbdbsr105006 using lr_veiculo.socvcltip

     whenever error continue
     fetch cbdbsr105006 into l_cpodes
     whenever error stop

     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode <> notfound then
           display "Erro SELECT cbdbsr105006 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
           exit program(1)
        end if
     end if

     close cbdbsr105006

     open cbdbsr105007 using lr_veiculo.mdtcod

     whenever error continue
     fetch cbdbsr105007 into l_mdtctrcod
     whenever error stop

     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode <> notfound then
           display "Erro SELECT cbdbsr105007 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
           exit program(1)
        end if
     end if

     close cbdbsr105007

     open cbdbsr105008 using lr_acompa.pstcoddig

     whenever error continue
     fetch cbdbsr105008 into l_nomgrr
     whenever error stop

     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode <> notfound then
           display "Erro SELECT cbdbsr105008 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
           exit program(1)
        end if
     end if

     close cbdbsr105008

     open cbdbsr105009 using lr_acompa.srrcoddig

     whenever error continue
     fetch cbdbsr105009 into l_srrnom
     whenever error stop

     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode <> notfound then
           display "Erro SELECT cbdbsr105009 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
           exit program(1)
        end if
     end if

     close cbdbsr105009

     open cbdbsr105010 using lr_acompa.atdsrvnum, lr_acompa.atdsrvano, lr_veiculo.mdtcod

     whenever error continue
     fetch cbdbsr105010 into lr_msglog.atldat, lr_msglog.atlhor
     whenever error stop

     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode = notfound then

           let lr_auxiliar.dh_ini_d = ctx01g07_trans_data(lr_acompa.atdetpdat,
                                                          lr_acompa.atdetphor)

           # ---> SOMA 2 MINUTOS NA DATA/HORA ACIONAMENTO
           let lr_auxiliar.dh_ini_d = (lr_auxiliar.dh_ini_d + 2 units minute)

           # ---> DATA/HORA DE TRANSMISSAO RECEBE DATA/HORA ACIONAMENTO + 2 MINUTOS
           call ctx01g07_pega_dtahor(lr_auxiliar.dh_ini_d)
                returning lr_msglog.atldat, lr_msglog.atlhor

           initialize lr_auxiliar to null

        else
           display "Erro SELECT cbdbsr105010 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
           exit program(1)
        end if
     end if

     close cbdbsr105010

        open cbdbsr105011 using lr_acompa.atdsrvnum,
                                lr_acompa.atdsrvano
        foreach cbdbsr105011 into lr_botao.caddat,
                                        lr_botao.cadhor,
                                        lr_botao.lclltt,
                                        lr_botao.lcllgt,
                                        lr_botao.mdtcod,
                                        lr_botao.mdtbotprgseq,
                                        lr_botao.mdtmvttipcod,
                                        lr_botao.mdtmvtstt,
                                        lr_botao.brrnom

        if lr_botao.mdtbotprgseq = 1 and lr_botao.mdtmvtstt <> 4 then  # BOTAO REC
                if lr_botao.caddat is null or lr_botao.cadhor is null then
                        let lr_auxiliar.dh_ini_d = ctx01g07_trans_data(lr_msglog.atldat,
                                                                     lr_msglog.atlhor)
                        # ---> SOMA 2 MINUTOS NA DATA/HORA TRANSMISSAO
                        let lr_auxiliar.dh_ini_d = (lr_auxiliar.dh_ini_d + 2 units minute)
                        # ---> DATA/HORA BOTAO REC RECEBE DATA/HORA TRANSMISSAO + 2 MINUTOS
                        call ctx01g07_pega_dtahor(lr_auxiliar.dh_ini_d)
                        returning lr_botao.caddat, lr_botao.cadhor
                        initialize lr_auxiliar to null
                else
                        let lr_botao_rec.caddat = lr_botao.caddat
                        let lr_botao_rec.cadhor = lr_botao.cadhor
                end if
                let lr_botao_rec.lclltt = lr_botao.lclltt
                let lr_botao_rec.lcllgt = lr_botao.lcllgt
                let lr_botao_rec.brrnom = lr_botao.brrnom

                ## Busca endereco da coordenada do botao
                let l_tempo = current
                call bdbsr105_end_botao(lr_botao_rec.lclltt,
                                        lr_botao_rec.lcllgt)
                     returning lr_botao_rec.coord,
                               lr_botao_rec.endereco

        else
                if lr_botao.mdtbotprgseq = 2 and lr_botao.mdtmvtstt <> 4 then # BOTAO INI
                        let lr_botao_ini.caddat = lr_botao.caddat
                        let lr_botao_ini.cadhor = lr_botao.cadhor
                        let lr_botao_ini.lclltt = lr_botao.lclltt
                        let lr_botao_ini.lcllgt = lr_botao.lcllgt
                        let lr_botao_ini.brrnom = lr_botao.brrnom

                        ## Busca endereco da coordenada do botao
                        let l_tempo = current
                        call bdbsr105_end_botao(lr_botao_ini.lclltt,
                                                lr_botao_ini.lcllgt)
                             returning lr_botao_ini.coord,
                                       lr_botao_ini.endereco

                        if lr_botao_ini.caddat is null or
                        lr_botao_ini.cadhor is null then
                                let l_desprezados = l_desprezados + 1

                                # ---> INICIALIZA AS VARIAVEIS
                                initialize lr_segurado,
                                	   lr_servico,
                                           lr_local,
                                           lr_destino,
                                           lr_liberado,
                                           lr_veiculo,
                                           lr_msglog,
                                           lr_botao_rec,
                                           lr_botao_ini,
                                           lr_botao_fim,
                                           lr_auxiliar to null

                                initialize l_cpodes           ,
                                  	   l_mdtctrcod        ,
                                  	   l_nomgrr           ,
                                  	   l_srrnom           ,
                                  	   l_data_atual       ,
                                  	   l_hora_atual       ,
                                  	   l_tipo_botao       ,
                                  	   l_dis_soc_srv      ,
                                  	   l_dis_rec_soc_srv  ,
                                  	   l_dis_ini_soc_srv  ,
                                  	   l_dis_fim_soc_srv  ,
                                  	   l_dis_fim_soc_qti  ,
                                  	   l_tipo             ,
                                  	   l_tmp_liberacao    ,
                                  	   l_tmp_acionamento  ,
                                  	   l_tmp_transmissao  ,
                                  	   l_tmp_qrurec       ,
                                  	   l_tmp_qruini       ,
                                  	   l_tmp_espseg       ,
                                  	   l_tmp_qrufim       ,
                                  	   l_tmp_totsrv        to null
                                let l_tempo_zerado      = "00:00:00"
                                initialize l_prev_segundo      ,
                                	   l_prev_intervalo    ,
                                	   l_aux_char          ,
                                	   l_aux_final         ,
                                	   l_aux_datetime      ,
                                	   l_dtahor_iniprev    ,
                                	   l_tmp_difprev       ,
                                	   l_resultado         ,
                                	   l_dis_soc_metros    ,
                                	   l_dis_rec_metros    ,
                                	   l_dis_ini_metros    ,
                                	   l_dis_fim_metros    ,
                                	   l_dis_qti_metros    ,
                                	   l_tmp_liberacao_c   ,
                                	   l_tmp_acionamento_c ,
                                	   l_tmp_transmissao_c ,
                                	   l_tmp_qrurec_c      ,
                                	   l_tmp_qruini_c      ,
                                	   l_tmp_espseg_c      ,
                                	   l_tmp_qrufim_c      ,
                                	   l_tmp_totsrv_c      ,
                                	   l_tmp_difprev_c     ,
                                	   l_cidcod            ,
                                	   l_ufdcod_sede       ,
                                	   l_cidnom_sede       to null

                                exit foreach
                                let ws.flgfim = true
                        end if
                else
                        if lr_botao.mdtbotprgseq = 3 and lr_botao.mdtmvtstt <> 4 then # BOTAO FIM
                           let lr_botao_fim.caddat = lr_botao.caddat
                           let lr_botao_fim.cadhor = lr_botao.cadhor
                           let lr_botao_fim.lclltt = lr_botao.lclltt
                           let lr_botao_fim.lcllgt = lr_botao.lcllgt
                           let lr_botao_fim.brrnom = lr_botao.brrnom

                           ## Busca endereco da coordenada do botao
                           let l_tempo = current
                           call bdbsr105_end_botao(lr_botao_fim.lclltt,
                                                   lr_botao_fim.lcllgt)
                                returning lr_botao_fim.coord,
                                          lr_botao_fim.endereco
                        end if
                end if
        end if
        end foreach
        close cbdbsr105011

        if ws.flgfim = true then
                continue foreach
        end if

        # ---> CALCULOS DAS DISTANCIAS
        let l_dis_soc_srv     = cts18g00(lr_local.lclltt,
                                lr_local.lcllgt,
                                lr_servico.srrltt,
                                lr_servico.srrlgt)

        let l_dis_rec_soc_srv = cts18g00(lr_local.lclltt,
                                 lr_local.lcllgt,
                                 lr_botao_rec.lclltt,
                                 lr_botao_rec.lcllgt)

        let l_dis_ini_soc_srv = cts18g00(lr_local.lclltt,
                                 lr_local.lcllgt,
                                 lr_botao_ini.lclltt,
                                 lr_botao_ini.lcllgt)

        let l_dis_fim_soc_srv = cts18g00(lr_local.lclltt,
                                 lr_local.lcllgt,
                                 lr_botao_fim.lclltt,
                                 lr_botao_fim.lcllgt)

        # Calcula distancia entre FIM e QTI
        if lr_destino.lclltt is null or lr_botao_fim.lclltt is null then
            let l_dis_fim_soc_qti = 0
        else
            let l_dis_fim_soc_qti = cts18g00(lr_destino.lclltt,
                                     lr_destino.lcllgt,
                                     lr_botao_fim.lclltt,
                                     lr_botao_fim.lcllgt)
        end if

        # ---> TRANSFORMA AS DISTANCIAS EM METROS
        let l_dis_soc_metros = ctx01g07_km_p_metro(l_dis_soc_srv)
        let l_dis_rec_metros = ctx01g07_km_p_metro(l_dis_rec_soc_srv)
        let l_dis_ini_metros = ctx01g07_km_p_metro(l_dis_ini_soc_srv)
        let l_dis_fim_metros = ctx01g07_km_p_metro(l_dis_fim_soc_srv)
        let l_dis_qti_metros = ctx01g07_km_p_metro(l_dis_fim_soc_qti)

        # ---> CALCULA O TEMPO DE LIBERACAO
        let l_tmp_liberacao   = ctx01g07_dif_tempo (lr_liberado.atdetpdat,
                                            lr_liberado.atdetphor,
                                            lr_servico.atddat,
                                            lr_servico.atdhor)

        # ---> CALCULA O TEMPO DE ACIONAMENTO
        let l_tmp_acionamento = ctx01g07_dif_tempo(lr_acompa.atdetpdat,
                                           lr_acompa.atdetphor,
                                           lr_liberado.atdetpdat,
                                           lr_liberado.atdetphor)

        # ---> CALCULA O TEMPO DE TRANSMISSAO
        let l_tmp_transmissao = ctx01g07_dif_tempo(lr_msglog.atldat,
                                           lr_msglog.atlhor,
                                           lr_acompa.atdetpdat,
                                           lr_acompa.atdetphor)

        if l_tmp_transmissao > "00:30:00" then
                let l_desprezados = l_desprezados + 1

                # ---> INICIALIZA AS VARIAVEIS
                initialize lr_segurado,
                	lr_servico,
                        lr_local,
                        lr_destino,
                        lr_liberado,
                        lr_veiculo,
                        lr_msglog,
                        lr_botao_rec,
                        lr_botao_ini,
                        lr_botao_fim,
                        lr_auxiliar to null

                initialize l_cpodes          ,
                    	   l_mdtctrcod       ,
                    	   l_nomgrr          ,
                    	   l_srrnom          ,
                    	   l_data_atual      ,
                    	   l_hora_atual      ,
                    	   l_tipo_botao      ,
                    	   l_dis_soc_srv     ,
                    	   l_dis_rec_soc_srv ,
                    	   l_dis_ini_soc_srv ,
                    	   l_dis_fim_soc_srv ,
                    	   l_dis_fim_soc_qti ,
                    	   l_tipo            ,
                    	   l_tmp_liberacao   ,
                    	   l_tmp_acionamento ,
                    	   l_tmp_transmissao ,
                    	   l_tmp_qrurec      ,
                    	   l_tmp_qruini      ,
                    	   l_tmp_espseg      ,
                    	   l_tmp_qrufim      ,
                    	   l_tmp_totsrv        to null
                let l_tempo_zerado      = "00:00:00"
                initialize l_prev_segundo	,
                	   l_prev_intervalo     ,
                	   l_aux_char           ,
                	   l_aux_final          ,
                	   l_aux_datetime       ,
                	   l_dtahor_iniprev     ,
                	   l_tmp_difprev        ,
                	   l_resultado          ,
                	   l_dis_soc_metros     ,
                	   l_dis_rec_metros     ,
                	   l_dis_ini_metros     ,
                	   l_dis_fim_metros     ,
                	   l_tmp_liberacao_c    ,
                	   l_tmp_acionamento_c  ,
                	   l_tmp_transmissao_c  ,
                	   l_tmp_qrurec_c       ,
                	   l_tmp_qruini_c       ,
                	   l_tmp_espseg_c       ,
                	   l_tmp_qrufim_c       ,
                	   l_tmp_totsrv_c       ,
                	   l_tmp_difprev_c      ,
                	   l_cidcod             ,
                	   l_ufdcod_sede        ,
                	   l_cidnom_sede       to null

                continue foreach

        end if

        # ---> CALCULA O TEMPO DE QRU-REC
        let l_tmp_qrurec      = ctx01g07_dif_tempo(lr_botao_rec.caddat,
                                           lr_botao_rec.cadhor,
                                           lr_msglog.atldat,
                                           lr_msglog.atlhor)

        if l_tmp_qrurec > "00:30:00" then

                let l_desprezados = l_desprezados + 1

                # ---> INICIALIZA AS VARIAVEIS
                initialize lr_segurado,
                	lr_servico,
                        lr_local,
                        lr_destino,
                        lr_liberado,
                        lr_veiculo,
                        lr_msglog,
                        lr_botao_rec,
                        lr_botao_ini,
                        lr_botao_fim,
                        lr_auxiliar to null

                initialize l_cpodes           ,
                	   l_mdtctrcod        ,
                	   l_nomgrr           ,
                	   l_srrnom           ,
                	   l_data_atual       ,
                	   l_hora_atual       ,
                	   l_tipo_botao       ,
                	   l_dis_soc_srv      ,
                	   l_dis_rec_soc_srv  ,
                	   l_dis_ini_soc_srv  ,
                	   l_dis_fim_soc_srv  ,
                	   l_dis_fim_soc_qti  ,
                	   l_tipo             ,
                	   l_tmp_liberacao    ,
                	   l_tmp_acionamento  ,
                	   l_tmp_transmissao  ,
                	   l_tmp_qrurec       ,
                	   l_tmp_qruini       ,
                	   l_tmp_espseg       ,
                	   l_tmp_qrufim       ,
                	   l_tmp_totsrv        to null
                let l_tempo_zerado      = "00:00:00"
                initialize l_prev_segundo      ,
                	   l_prev_intervalo    ,
                	   l_aux_char          ,
                	   l_aux_final         ,
                	   l_aux_datetime      ,
                	   l_dtahor_iniprev    ,
                	   l_tmp_difprev       ,
                	   l_resultado         ,
                	   l_dis_soc_metros    ,
                	   l_dis_rec_metros    ,
                	   l_dis_ini_metros    ,
                	   l_dis_fim_metros    ,
                	   l_tmp_liberacao_c   ,
                	   l_tmp_acionamento_c ,
                	   l_tmp_transmissao_c ,
                	   l_tmp_qrurec_c      ,
                	   l_tmp_qruini_c      ,
                	   l_tmp_espseg_c      ,
                	   l_tmp_qrufim_c      ,
                	   l_tmp_totsrv_c      ,
                	   l_tmp_difprev_c     ,
                	   l_cidcod            ,
                	   l_ufdcod_sede       ,
                	   l_cidnom_sede       to null

                continue foreach
        end if

       # ---> CALCULA O TEMPO DE QRU-INI
       let l_tmp_qruini      = ctx01g07_dif_tempo(lr_botao_ini.caddat,
                                                  lr_botao_ini.cadhor,
                                                  lr_botao_rec.caddat,
                                                  lr_botao_rec.cadhor)

       # ---> CALCULA O TEMPO DE ESPERA DO SEGURADO
       let l_tmp_espseg      = ctx01g07_dif_tempo(lr_botao_ini.caddat,
                                                  lr_botao_ini.cadhor,
                                                  lr_liberado.atdetpdat,
                                                  lr_liberado.atdetphor)

       # ---> CALCULA O TEMPO DE QRU-FIM
       let l_tmp_qrufim      = ctx01g07_dif_tempo(lr_botao_fim.caddat,
                                                  lr_botao_fim.cadhor,
                                                  lr_botao_ini.caddat,
                                                  lr_botao_ini.cadhor)

       # ---> CALCULA O TEMPO TOTAL DO SERVICO
       let l_tmp_totsrv      = ctx01g07_dif_tempo(lr_botao_fim.caddat,
                                                  lr_botao_fim.cadhor,
                                                  lr_liberado.atdetpdat,
                                                  lr_liberado.atdetphor)

       # ---> SE O TEMPO FOR NEGATIVO ASSUME "00:00:00"

       if l_tmp_liberacao < "00:00:00" then
        let l_tmp_liberacao = "00:00:00"
       end if

       if l_tmp_acionamento < "00:00:00" then
        let l_tmp_acionamento = "00:00:00"
       end if

       if l_tmp_transmissao < "00:00:00" then
                let l_tmp_transmissao = "00:00:00"
       end if

       if l_tmp_qrurec < "00:00:00" then
                let l_tmp_qrurec = "00:00:00"
       end if

       if l_tmp_qruini < "00:00:00" then
                let l_tmp_qruini = "00:00:00"
       end if

       if l_tmp_espseg < "00:00:00" then
                let l_tmp_espseg = "00:00:00"
       end if

       if l_tmp_qrufim < "00:00:00" then
                let l_tmp_qrufim = "00:00:00"
       end if

       if l_tmp_totsrv < "00:00:00" then
                let l_tmp_totsrv = "00:00:00"
       end if

       # ---> REMOVE OS ESPACOS A ESQUERDA DOS TEMPOS
       let l_tmp_liberacao_c   = ctx01g07_rem_eps_esq(l_tmp_liberacao)
       let l_tmp_acionamento_c = ctx01g07_rem_eps_esq(l_tmp_acionamento)
       let l_tmp_transmissao_c = ctx01g07_rem_eps_esq(l_tmp_transmissao)
       let l_tmp_qrurec_c      = ctx01g07_rem_eps_esq(l_tmp_qrurec)
       let l_tmp_qruini_c      = ctx01g07_rem_eps_esq(l_tmp_qruini)
       let l_tmp_espseg_c      = ctx01g07_rem_eps_esq(l_tmp_espseg)
       let l_tmp_qrufim_c      = ctx01g07_rem_eps_esq(l_tmp_qrufim)
       let l_tmp_totsrv_c      = ctx01g07_rem_eps_esq(l_tmp_totsrv)

       # ---> CALCULA A DATA/HORA DO INICIO PREVISTO
       if lr_servico.atddatprg is null and
       lr_servico.atdhorprg is null then

        # ---> SERVICO IMEDIATO

        # ---> FORMATA A VARIAVEL PREVISAO PARA O TIPO hh:mm:ss
        let l_prev_segundo   = lr_servico.atdprvdat

        # ---> COLOCA A VARIAVEL PREVISAO NO TIPO INTERVALO
        let l_prev_intervalo = (l_prev_segundo - l_tempo_zerado)
        let l_prev_segundo   = lr_acompa.atdetphor

        # ---> COLOCA A DATA/HORA ACIONAMENTO NO FORMATO datetime year to second
        let l_aux_datetime   = ctx01g07_trans_data(lr_acompa.atdetpdat, l_prev_segundo)

        # ---> SOMA O INTERVALO DA PREVISAO
        let l_aux_datetime   = (l_aux_datetime + l_prev_intervalo)

        # ---> JOGA PARA A VARIAVEL CHAR, COM A SOMA DA PREVISAO
        let l_aux_char     = l_aux_datetime

        # ---> MONTA A DATA FINAL
        let l_aux_final =  l_aux_char[9,10], "/", # DIA
                           l_aux_char[6,7],  "/", # MES
                           l_aux_char[1,4],  " ", # ANO
                           l_aux_char[12,19]      # HORA

        # ---> VARIAVEL CHAR RECEBE A DATA NO FORMATO yyyy-mm-dd hh:mm:ss
        let l_aux_char = l_aux_final

       else
                # --> SERVICO PROGRAMADO

                # ---> VARIAVEL DO TIPO hh:mm:ss
                let l_prev_segundo = lr_servico.atdhorprg

                let l_aux_char     = lr_servico.atddatprg using "yyyy-mm-dd", " ", l_prev_segundo
                
                # ---> MONTA A DATA FINAL
                let l_aux_char =  l_aux_char[9,10], "/", # DIA
                                  l_aux_char[6,7],  "/", # MES
                                  l_aux_char[1,4],  " ", # ANO
                                  l_aux_char[12,19]      # HORA

       end if

       let l_dtahor_iniprev = l_aux_char

       # ---> VERIFICA O RESULTADO (ATRASADO OU PREVISTO)

       # ---> TRANSFORMA AS VARIAVEIS PARA O TIPO yyyy-mm-dd hh:mm:ss
       let lr_auxiliar.dh_ini_c = ctx01g07_trans_data(lr_botao_ini.caddat,
                                                      lr_botao_ini.cadhor)

       let lr_auxiliar.dh_pre_c = l_dtahor_iniprev[7,10], "-", # ANO
                                  l_dtahor_iniprev[1,2],  "-", # MES
                                  l_dtahor_iniprev[4,5],  " ", # ANO
                                  l_dtahor_iniprev[12,19]      # HORA

       let lr_auxiliar.dh_ini_d = lr_auxiliar.dh_ini_c
       let lr_auxiliar.dh_pre_d = lr_auxiliar.dh_pre_c

       if lr_auxiliar.dh_ini_d > lr_auxiliar.dh_pre_d then
        let l_resultado = "ATRASADO"
       else
                let l_resultado = "PREVISTO"
       end if

       # ---> CALCULA TEMPO DIFERENTE DO PREVISTO
       let lr_auxiliar.data = l_dtahor_iniprev[1,2], "/",  # DIA
                              l_dtahor_iniprev[4,5], "/",  # MES
                              l_dtahor_iniprev[7,10]       # ANO

       let lr_auxiliar.hora = l_dtahor_iniprev[12,19]

       let l_tmp_difprev = ctx01g07_dif_tempo(lr_botao_ini.caddat,
                                              lr_botao_ini.cadhor,
                                              lr_auxiliar.data,
                                              lr_auxiliar.hora)

       if l_tmp_difprev < "00:00:00" then
                let l_tmp_difprev = "00:00:00"
       end if
       if l_tmp_difprev > "00:00:00" then
          let l_resultado = "ATRASADO"
       else
          let l_resultado = "PREVISTO"
       end if 
       if l_tmp_difprev = "00:00:00" then
          let l_resultado = "PREVISTO"
       end if 

       # ---> REMOVE OS ESPACOS A ESQUERDA DOS TEMPOS
       let l_tmp_difprev_c     = ctx01g07_rem_eps_esq(l_tmp_difprev)

       # -> BUSCA A UF E CIDADE SEDE DO SERVICO
       whenever error continue
       # -> BUSCA CIDCOD
       open cbdbsr105012 using lr_local.ufdcod, lr_local.cidnom
       fetch cbdbsr105012 into l_cidcod
       close cbdbsr105012

       # -> BUSCA CIDSEDCOD
       open cbdbsr105013 using l_cidcod
       fetch cbdbsr105013 into l_cidcod
       close cbdbsr105013

       # -> BUSCA UF E CIDADE DA CIDADE SEDE
       open cbdbsr105014 using l_cidcod
       fetch cbdbsr105014 into l_ufdcod_sede, l_cidnom_sede

       if sqlca.sqlcode = notfound then
          let l_ufdcod_sede = lr_local.ufdcod
          let l_cidnom_sede = lr_local.cidnom
       end if

       close cbdbsr105014


       open cbdbsr105017 using lr_acompa.atdsrvnum,
                               lr_acompa.atdsrvano

       fetch cbdbsr105017 into lr_segurado.succod,
                               lr_segurado.ramcod,
                               lr_segurado.aplnumdig,
                               lr_segurado.itmnumdig
       close cbdbsr105017


       {open cbdbsr105019 using lr_segurado.succod,
                               lr_segurado.aplnumdig,
                               lr_segurado.itmnumdig

       fetch cbdbsr105019 into lr_segurado.dctnumseq

       close cbdbsr105019}


       {open cbdbsr105018 using lr_segurado.succod,
                               lr_segurado.aplnumdig,
                               lr_segurado.itmnumdig,
                               lr_segurado.dctnumseq

       fetch cbdbsr105018 into lr_segurado.segnom

       close cbdbsr105018 }

       open cbdbsr105020 using lr_acompa.atdsrvnum,
                               lr_acompa.atdsrvano


       fetch cbdbsr105020 into lr_servico.c24astcod,
                               lr_servico.c24astdes

       close cbdbsr105020
       
       open cbdbsr105022 using lr_acompa.atdsrvnum,
                               lr_acompa.atdsrvano


       fetch cbdbsr105022 into lr_tmaligldo.ligdat, 
                               lr_tmaligldo.lighorinc,
                               lr_tmaligldo.lighorfnl

       close cbdbsr105022  
       
       let lr_tmaabtldo = lr_tmaligldo.lighorfnl  - lr_tmaligldo.lighorinc 
       whenever error stop

       output to report bdbsr105_relatorio(lr_servico.ciaempcod,     # 1
                                           lr_segurado.succod,       # 2
                                           lr_segurado.ramcod,       # 3
                                           lr_segurado.aplnumdig,    # 4
                                           lr_segurado.itmnumdig,    # 5
                                           lr_servico.nom,	     # 6
                                           lr_servico.vclmrccod,     # 7
                                           lr_servico.vclmrcnom,     # 8
                                           lr_servico.vcllicnum,     # 9
                                           lr_servico.vclanomdl,     # 10
                                           lr_servico.c24astcod,     # 11
                                           lr_servico.c24astdes,     # 12
                                           lr_servico.atdsrvorg,     # 13
                                           lr_acompa.atdsrvnum,      # 14
                                           lr_acompa.atdsrvano,      # 15
                                           l_ufdcod_sede,            # 16
                                           l_cidnom_sede,            # 17
                                           lr_local.ufdcod,          # 18
                                           lr_local.cidnom,          # 19
                                           lr_local.brrnom,          # 20
                                           lr_servico.atddat,        # 21
                                           lr_servico.atdhor,        # 22
                                           lr_liberado.atdetpdat,    # 23
                                           lr_liberado.atdetphor,    # 24
                                           lr_acompa.atdetpdat,      # 25
                                           lr_acompa.atdetphor,      # 26
                                           l_dis_soc_metros,         # 27
                                           lr_acompa.pstcoddig,      # 28
                                           l_nomgrr,                 # 29
                                           lr_veiculo.atdvclsgl,     # 30
                                           l_cpodes,                 # 31
                                           lr_acompa.srrcoddig,      # 32
                                           l_srrnom,                 # 33
                                           lr_msglog.atldat,         # 34
                                           lr_msglog.atlhor,         # 35
                                           lr_botao_rec.caddat,      # 36
                                           lr_botao_rec.cadhor,      # 37
                                           l_dis_rec_metros,         # 38
                                           lr_botao_rec.coord,       # 39
                                           lr_botao_rec.endereco,    # 40
                                           lr_botao_ini.caddat,      # 41
                                           lr_botao_ini.cadhor,      # 42
                                           l_dis_ini_metros,         # 43
                                           lr_botao_ini.coord,       # 44
                                           lr_botao_ini.endereco,    # 45
                                           lr_botao_fim.caddat,      # 46
                                           lr_botao_fim.cadhor,      # 47
                                           l_dis_fim_metros,         # 48
                                           lr_botao_fim.coord,       # 49
                                           lr_botao_fim.endereco,    # 50
                                           lr_veiculo.mdtcod,        # 51
                                           l_mdtctrcod,              # 52
                                           l_tipo,                   # 53
                                           l_tmp_liberacao_c,        # 54
                                           l_tmp_acionamento_c,      # 55
                                           lr_servico.atdprvdat,     # 56
                                           l_tmp_transmissao_c,      # 57
                                           l_tmp_qrurec_c,           # 58
                                           l_tmp_qruini_c,           # 59
                                           l_tmp_espseg_c,           # 60
                                           l_tmp_qrufim_c,           # 61
                                           l_tmp_totsrv_c,           # 63
                                           l_dtahor_iniprev,         # 64
                                           l_resultado,              # 65
                                           l_tmp_difprev_c,          # 66
                                           lr_botao_rec.brrnom,      # 67
                                           lr_botao_ini.brrnom,      # 68
                                           lr_botao_fim.brrnom,      # 69
                                           l_dis_qti_metros,         # 70
                                           lr_tmaligldo.ligdat,        # 71  
                                           lr_tmaligldo.lighorinc,     # 72
                                           lr_tmaligldo.lighorfnl,     # 73  
                                           lr_tmaabtldo)                # 74
                                           
       output to report bdbsr105_relatorio_txt(lr_servico.ciaempcod,     # 1
                                           lr_segurado.succod,       # 2
                                           lr_segurado.ramcod,       # 3
                                           lr_segurado.aplnumdig,    # 4
                                           lr_segurado.itmnumdig,    # 5
                                           lr_servico.nom,	     # 6
                                           lr_servico.vclmrccod,     # 7
                                           lr_servico.vclmrcnom,     # 8
                                           lr_servico.vcllicnum,     # 9
                                           lr_servico.vclanomdl,     # 10
                                           lr_servico.c24astcod,     # 11
                                           lr_servico.c24astdes,     # 12
                                           lr_servico.atdsrvorg,     # 13
                                           lr_acompa.atdsrvnum,      # 14
                                           lr_acompa.atdsrvano,      # 15
                                           l_ufdcod_sede,            # 16
                                           l_cidnom_sede,            # 17
                                           lr_local.ufdcod,          # 18
                                           lr_local.cidnom,          # 19
                                           lr_local.brrnom,          # 20
                                           lr_servico.atddat,        # 21
                                           lr_servico.atdhor,        # 22
                                           lr_liberado.atdetpdat,    # 23
                                           lr_liberado.atdetphor,    # 24
                                           lr_acompa.atdetpdat,      # 25
                                           lr_acompa.atdetphor,      # 26
                                           l_dis_soc_metros,         # 27
                                           lr_acompa.pstcoddig,      # 28
                                           l_nomgrr,                 # 29
                                           lr_veiculo.atdvclsgl,     # 30
                                           l_cpodes,                 # 31
                                           lr_acompa.srrcoddig,      # 32
                                           l_srrnom,                 # 33
                                           lr_msglog.atldat,         # 34
                                           lr_msglog.atlhor,         # 35
                                           lr_botao_rec.caddat,      # 36
                                           lr_botao_rec.cadhor,      # 37
                                           l_dis_rec_metros,         # 38
                                           lr_botao_rec.coord,       # 39
                                           lr_botao_rec.endereco,    # 40
                                           lr_botao_ini.caddat,      # 41
                                           lr_botao_ini.cadhor,      # 42
                                           l_dis_ini_metros,         # 43
                                           lr_botao_ini.coord,       # 44
                                           lr_botao_ini.endereco,    # 45
                                           lr_botao_fim.caddat,      # 46
                                           lr_botao_fim.cadhor,      # 47
                                           l_dis_fim_metros,         # 48
                                           lr_botao_fim.coord,       # 49
                                           lr_botao_fim.endereco,    # 50
                                           lr_veiculo.mdtcod,        # 51
                                           l_mdtctrcod,              # 52
                                           l_tipo,                   # 53
                                           l_tmp_liberacao_c,        # 54
                                           l_tmp_acionamento_c,      # 55
                                           lr_servico.atdprvdat,     # 56
                                           l_tmp_transmissao_c,      # 57
                                           l_tmp_qrurec_c,           # 58
                                           l_tmp_qruini_c,           # 59
                                           l_tmp_espseg_c,           # 60
                                           l_tmp_qrufim_c,           # 61
                                           l_tmp_totsrv_c,           # 63
                                           l_dtahor_iniprev,         # 64
                                           l_resultado,              # 65
                                           l_tmp_difprev_c,          # 66
                                           lr_botao_rec.brrnom,      # 67
                                           lr_botao_ini.brrnom,      # 68
                                           lr_botao_fim.brrnom,      # 69
                                           l_dis_qti_metros,         # 70
                                           lr_tmaligldo.ligdat,        # 71  
                                           lr_tmaligldo.lighorinc,     # 72
                                           lr_tmaligldo.lighorfnl,     # 73  
                                           lr_tmaabtldo)                # 74

       # ---> INICIALIZACAO DAS VARIAVEIS
       initialize lr_segurado,
                  lr_tmaligldo,
       		        lr_servico,
                  lr_local,
                  lr_destino,
                  lr_liberado,
                  lr_veiculo,
                  lr_msglog,
                  lr_botao_rec,
                  lr_botao_ini,
                  lr_botao_fim,
                  lr_auxiliar,
                  lr_tmaabtldo to null

       initialize l_cpodes          ,
       		  l_mdtctrcod       ,
       		  l_nomgrr          ,
       		  l_srrnom          ,
       		  l_data_atual      ,
       		  l_hora_atual      ,
       		  l_tipo_botao      ,
       		  l_dis_soc_srv     ,
       		  l_dis_rec_soc_srv ,
       		  l_dis_ini_soc_srv ,
       		  l_dis_fim_soc_srv ,
       		  l_dis_fim_soc_qti ,
       		  l_tipo            ,
       		  l_tmp_liberacao   ,
       		  l_tmp_acionamento ,
       		  l_tmp_transmissao ,
       		  l_tmp_qrurec      ,
       		  l_tmp_qruini      ,
       		  l_tmp_espseg      ,
       		  l_tmp_qrufim      ,
       		  l_tmp_totsrv      to null
       let l_tempo_zerado      = "00:00:00"
       initialize l_prev_segundo      ,
           	  l_prev_intervalo    ,
           	  l_aux_char          ,
           	  l_aux_final         ,
           	  l_aux_datetime      ,
           	  l_dtahor_iniprev    ,
           	  l_tmp_difprev       ,
           	  l_resultado         ,
           	  l_dis_soc_metros    ,
           	  l_dis_rec_metros    ,
           	  l_dis_ini_metros    ,
           	  l_dis_fim_metros    ,
           	  l_tmp_liberacao_c   ,
           	  l_tmp_acionamento_c ,
           	  l_tmp_transmissao_c ,
           	  l_tmp_qrurec_c      ,
           	  l_tmp_qruini_c      ,
           	  l_tmp_espseg_c      ,
           	  l_tmp_qrufim_c      ,
           	  l_tmp_totsrv_c      ,
           	  l_tmp_difprev_c     ,
           	  l_cidcod            ,
           	  l_ufdcod_sede       ,
           	  l_cidnom_sede       to null

       end foreach

close cbdbsr105001

finish report bdbsr105_relatorio
finish report bdbsr105_relatorio_txt

call bdbsr105_envia_email(l_data_inicio, l_data_fim)

display " "
display "QTD.REGISTROS LIDOS......: ", l_lidos       using "<<<<<<<<&"
display "QTD.REGISTROS DESPREZADOS: ", l_desprezados using "<<<<<<<<&"
display " "

end function

#-------------------------------------#
report bdbsr105_relatorio(lr_parametro)
#-------------------------------------#

  define lr_parametro       record
         ciaempcod          like datmservico.ciaempcod, # 1
         succod             like datrligapol.succod,    # 2
         ramcod             like datrligapol.ramcod,    # 3
         aplnumdig          like datrligapol.aplnumdig, # 4
         itmnumdig          like datrligapol.itmnumdig, # 5
         nom	 	    like datmservico.nom,       # 6 Nome Padrao
         #segnom             like gsakseg.segnom,       # 6
         vclmrccod  	    like agbkmarca.vclmrccod,   # 7
         vclmrcnom  	    like agbkmarca.vclmrcnom,   # 8
         vcllicnum          like datmservico.vcllicnum, # 9
         vclanomdl          like datmservico.vclanomdl, # 10
         c24astcod          like datmligacao.c24astcod, # 11
         c24astdes          like datkassunto.c24astdes, # 12
         atdsrvorg          like datmservico.atdsrvorg, # 13
         atdsrvnum          like datmsrvacp.atdsrvnum,  # 14
         atdsrvano          like datmsrvacp.atdsrvano,  # 15
         ufdcod_sede        like datmlcl.ufdcod,        # 16
         cidnom_sede        like datmlcl.cidnom,        # 17
         ufdcod             like datmlcl.ufdcod,        # 18
         cidnom             like datmlcl.cidnom,        # 19
         brrnom             like datmlcl.brrnom,        # 20
         atddat             like datmservico.atddat,    # 21
         atdhor             like datmservico.atdhor,    # 22
         lib_atdetpdat      like datmsrvacp.atdetpdat,  # 23
         lib_atdetphor      like datmsrvacp.atdetphor,  # 24
         acn_atdetpdat      like datmsrvacp.atdetpdat,  # 25
         acn_atdetphor      like datmsrvacp.atdetphor,  # 26
         dis_soc_srv        integer,                    # 27
         pstcoddig          like dpaksocor.pstcoddig,   # 28
         nomgrr             like dpaksocor.nomgrr,      # 29
         atdvclsgl          like datkveiculo.atdvclsgl, # 30
         cpodes             like iddkdominio.cpodes,    # 31
         srrcoddig          like datmsrvacp.srrcoddig,  # 32
         srrnom             like datksrr.srrnom,        # 33
         msglog_atldat      like datmmdtlog.atldat,     # 34
         msglog_atlhor      like datmmdtlog.atlhor,     # 35
         rec_atdetpdat      like datmmdtmvt.caddat,     # 36
         rec_atdetphor      like datmmdtmvt.cadhor,     # 37
         dis_rec_soc_srv    integer,                    # 38
         rec_coord          char(30),                   # 39
         rec_end            char(100),                  # 40
         ini_atdetpdat      like datmmdtmvt.caddat,     # 41
         ini_atdetphor      like datmmdtmvt.cadhor,     # 42
         dis_ini_soc_srv    integer,                    # 43
         ini_coord          char(30),                   # 44
         ini_end            char(100),                  # 45
         fim_atdetpdat      like datmmdtmvt.caddat,     # 46
         fim_atdetphor      like datmmdtmvt.cadhor,     # 47
         dis_fim_soc_srv    integer,                    # 48
         fim_coord          char(30),                   # 49
         fim_end            char(100),                  # 50
         mdtcod             like datkveiculo.mdtcod,    # 51
         mdtctrcod          like datkmdt.mdtctrcod,     # 52
         tipo               char(10),                   # 53
         tmp_liberacao      char(20),                   # 54
         tmp_acionamento    char(20),                   # 55
         atdprvdat          like datmservico.atdprvdat, # 56
         tmp_transmissao    char(20),                   # 57
         tmp_qrurec         char(20),                   # 58
         tmp_qruini         char(20),                   # 59
         tmp_espseg         char(20),                   # 60
         tmp_qrufim         char(20),                   # 61
         tmp_totsrv         char(20),                   # 63
         dtahor_iniprev     char(19),                   # 64
         resultado          char(08),                   # 65
         tmp_difprev        char(20),                   # 66
         recbrrnom          char(40),                   # 67
         inibrrnom          char(40),                   # 68
         fimbrrnom          char(40),                   # 69
         dis_fim_soc_qti    integer,                    # 70
         ligdat             like datmservico.atddat,    # 71
         lighorinc          like datmservico.atdhor, # 72
         lighorfnl          like datmservico.atdlibhor, # 73
         lr_tmaabtldo interval hour(3) to second           # 74
  end record

  define l_hora_segundos1   datetime hour to second,
         l_hora_segundos2   datetime hour to second,
         l_hora_segundos3   datetime hour to second,
         l_hora_segundos4   datetime hour to second,
         l_hora_segundos5   datetime hour to second,
         l_hora_segundos6   datetime hour to second,
         l_hora_segundos7   datetime hour to second,
         l_tmp_zero         interval hour(06) to second,
         l_tmp_15           interval hour(06) to second,
         l_tmp_30           interval hour(06) to second,
         l_tmp_45           interval hour(06) to second,
         l_tmp_60           interval hour(06) to second,
         l_texto            char(15)

  output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    02

  format

     first page header

        print "EMPRESA",                            ASCII(09),  # 1
              "SUC",				    ASCII(09),  # 2
              "RAMO",				    ASCII(09),  # 3
              "APL",				    ASCII(09),  # 4
              "ITEM",				    ASCII(09),  # 5
              "SEGURADO",			    ASCII(09),  # 6
              "COD MARCA",			    ASCII(09),  # 7
              "MARCA VEIC",			    ASCII(09),  # 8
              "PLACA",				    ASCII(09),  # 9
              "ANO MOD",			    ASCII(09),  # 10
              "COD ASSUNTO",			    ASCII(09),  # 11
              "DESC ASSUNTO",			    ASCII(09),  # 12
              "ORIGEM",                             ASCII(09),  # 13  # ---> ASCII(09) = TAB
              "SERVICO",                            ASCII(09),  # 14
              "DATA DO ACIONAMENTO",                ASCII(09),  # 15
              "TIPO",                               ASCII(09),  # 16
              "UF/SEDE",                            ASCII(09),  # 17
              "CIDADE/SEDE",                        ASCII(09),  # 18
              "UF",                                 ASCII(09),  # 19
              "CIDADE",                             ASCII(09),  # 20
              "BAIRRO",                             ASCII(09),  # 21
              "DATA/HORA ABERTURA  LAUDO",          ASCII(09),  # 72
              "DATA/HORA FECHAMENTO LAUDO",         ASCII(09),  # 73
              "TMA",                                ASCII(09),  # 74  
              "DATA/HORA ATENDIMENTO",              ASCII(09),  # 22
              "DATA/HORA LIBERACAO",                ASCII(09),  # 23
              "TEMPO DE LIBERACAO",                 ASCII(09),  # 24
              "DATA/HORA ACIONAMENTO",              ASCII(09),  # 25
              "TEMPO DE ACIONAMENTO",               ASCII(09),  # 26
              "DATA/HORA DO INICIO PREVISTO",       ASCII(09),  # 27
              "PREVISAO DO SERVICO",                ASCII(09),  # 28
              "DIST. ACIONAMENTO SOCORR. - SERV.",  ASCII(09),  # 29
              "PRESTADOR",                          ASCII(09),  # 30
              "VEICULO",                            ASCII(09),  # 31
              "TIPO DE VEICULO",                    ASCII(09),  # 32
              "SOCORRISTA",                         ASCII(09),  # 33
              "DATA/HORA TRANSMISSAO DO SERVICO",   ASCII(09),  # 34
              "TEMPO DE TRANSMISSAO",               ASCII(09),  # 35
              "DATA/HORA BOTAO REC SOCORRISTA",     ASCII(09),  # 36
              "TEMPO DO QRU-REC",                   ASCII(09),  # 37
              "DIST. BOTAO REC SOCORR. - SERV.",    ASCII(09),  # 38
              "BAIRRO NO REC",                      ASCII(09),  # 39
              "COORDENADAS DO REC",                 ASCII(09),  # 40
              "LOCAL DO REC",                       ASCII(09),  # 41
              "DATA/HORA BOTAO INI SOCORRISTA",     ASCII(09),  # 42
              "TEMPO DO QRU-INI",                   ASCII(09),  # 43
              "TEMPO DE ESPERA DO SEGURADO",        ASCII(09),  # 44
              "RESULTADO",                          ASCII(09),  # 45
              "TEMPO DE ATRASO",                    ASCII(09),  # 46
              "DIST. BOTAO INI SOCORR. - SERV.",    ASCII(09),  # 47
              "BAIRRO NO INI",                      ASCII(09),  # 48
              "COORDENADAS DO INI",                 ASCII(09),  # 49
              "LOCAL DO INI",                       ASCII(09),  # 50
              "DATA/HORA BOTAO FIM SOCORRISTA",     ASCII(09),  # 51
              "TEMPO DE QRU-FIM",                   ASCII(09),  # 52
              "TEMPO TOTAL DO SERVICO",             ASCII(09),  # 53
              "DIST. BOTAO FIM SOCORR. - SERV.",    ASCII(09),  # 54
              "BAIRRO NO FIM",                      ASCII(09),  # 55
              "COORDENADAS DO FIM",                 ASCII(09),  # 56
              "LOCAL DO FIM",                       ASCII(09),  # 57
              "DISTANCIA FIM-QTI",                  ASCII(09),  # 58
              "MDT/WVT",                            ASCII(09),  # 59
              "CONTROLADORA",                       ASCII(09),  # 60
              "PREVISAO DESCRICAO"                              # 61


     let l_tmp_zero = "00:00:00"
     let l_tmp_15   = "00:15:00"
     let l_tmp_30   = "00:30:00"
     let l_tmp_45   = "00:45:00"
     let l_tmp_60   = "01:00:00"

  on every row

     let l_hora_segundos1  = lr_parametro.atdhor
     let l_hora_segundos2  = lr_parametro.lib_atdetphor
     let l_hora_segundos3  = lr_parametro.acn_atdetphor
     let l_hora_segundos4  = lr_parametro.msglog_atlhor
     let l_hora_segundos5  = lr_parametro.rec_atdetphor
     let l_hora_segundos6  = lr_parametro.ini_atdetphor
     let l_hora_segundos7  = lr_parametro.fim_atdetphor

     print  lr_parametro.ciaempcod,  ASCII(09); #1


     if lr_parametro.succod is null or lr_parametro.succod = "" then
     	print "NAO CADASTRADO", ASCII(09);
     else
     print lr_parametro.succod, ASCII(09); #2
     end if

     if lr_parametro.ramcod is null or lr_parametro.ramcod = "" then
     	print "NAO CADASTRADO", ASCII(09);
     else
     print lr_parametro.ramcod, ASCII(09);#3
     end if

     if lr_parametro.aplnumdig is null or lr_parametro.aplnumdig = "" then
     	print "NAO CADASTRADO", ASCII(09);
     else
     print lr_parametro.aplnumdig, ASCII(09);#4
     end if

     if lr_parametro.itmnumdig is null or lr_parametro.itmnumdig = "" then
     	print "NAO CADASTRADO", ASCII(09);
     else
     print lr_parametro.itmnumdig, ASCII(09);#5
     end if

     {if lr_parametro.segnom is null or lr_parametro.segnom = "" then
     	print "NAO CADASTRADO", ASCII(09);
     else
     print lr_parametro.segnom, ASCII(09);#6
     end if}

     if lr_parametro.nom is null or lr_parametro.nom = "" then
     	print "NAO CADASTRADO", ASCII(09);
     else
     print lr_parametro.nom, ASCII(09);#6
     end if


     if lr_parametro.vclmrccod is null or lr_parametro.vclmrccod = "" then
     	print "NAO CADASTRADO", ASCII(09);
     else
     print lr_parametro.vclmrccod, ASCII(09);#7
     end if

     if lr_parametro.vclmrcnom is null or lr_parametro.vclmrcnom = "" then
     	print "NAO CADASTRADO", ASCII(09);
     else
     print lr_parametro.vclmrcnom, ASCII(09);#8
     end if

     if lr_parametro.vcllicnum is null or lr_parametro.vcllicnum = "" then
     	print "NAO CADASTRADO", ASCII(09);
     else
     print lr_parametro.vcllicnum, ASCII(09);#9
     end if

     if lr_parametro.vclanomdl is null or lr_parametro.vclanomdl = "" then
     	print "NAO CADASTRADO", ASCII(09);
     else
     print lr_parametro.vclanomdl, ASCII(09);#10
     end if

     if lr_parametro.c24astcod is null or lr_parametro.c24astcod = "" then
     	print "NAO CADASTRADO", ASCII(09);
     else
     print lr_parametro.c24astcod, ASCII(09);#11
     end if

     if lr_parametro.c24astdes is null or lr_parametro.c24astdes = "" then
     	print "NAO CADASTRADO", ASCII(09);
     else
     print lr_parametro.c24astdes, ASCII(09);#12
     end if

     print  lr_parametro.atdsrvorg       using "&&&&&",                                     ASCII(09); #13
     print  lr_parametro.atdsrvnum       using "&&&&&&&", "-",                              
            lr_parametro.atdsrvano       using "&&",                                        ASCII(09); # 14
     print  lr_parametro.acn_atdetpdat   using "yyyy-mm-dd",                                ASCII(09); # 15
     print  lr_parametro.tipo            clipped,                                           ASCII(09); # 16
     print  lr_parametro.ufdcod_sede     clipped,                                           ASCII(09); # 17
     print  lr_parametro.cidnom_sede     clipped,                                           ASCII(09); # 18
     print  lr_parametro.ufdcod          clipped,                                           ASCII(09); # 19
     print  lr_parametro.cidnom          clipped,                                           ASCII(09); # 20
     print  lr_parametro.brrnom          clipped,                                           ASCII(09); # 21
     print  lr_parametro.ligdat          using "yyyy-mm-dd", " ", lr_parametro.lighorinc,   ASCII(09); # 72
     print  lr_parametro.ligdat          using "yyyy-mm-dd", " ", lr_parametro.lighorfnl,   ASCII(09); # 73  
     print  lr_parametro.lr_tmaabtldo,                                                      ASCII(09); # 74   
     print  lr_parametro.atddat          using "yyyy-mm-dd", " ", l_hora_segundos1,         ASCII(09); # 22
     print  lr_parametro.lib_atdetpdat   using "yyyy-mm-dd", " ", l_hora_segundos2,         ASCII(09); # 23
     print  lr_parametro.tmp_liberacao   clipped,                                           ASCII(09); # 24
     print  lr_parametro.acn_atdetpdat   using "yyyy-mm-dd", " ", l_hora_segundos3,         ASCII(09); # 25
     print  lr_parametro.tmp_acionamento clipped,                                           ASCII(09); # 26
     print  lr_parametro.dtahor_iniprev  clipped,                                           ASCII(09); # 27
     print  lr_parametro.atdprvdat,                                                         ASCII(09); # 28
     print  lr_parametro.dis_soc_srv     using "<<<<<<<<&",                                 ASCII(09); # 29
     print  lr_parametro.pstcoddig       using "&&&&&&", " ", lr_parametro.nomgrr,          ASCII(09); # 30
     print  lr_parametro.atdvclsgl       clipped,                                           ASCII(09); # 31
     print  lr_parametro.cpodes          clipped,                                           ASCII(09); # 32
     print  lr_parametro.srrcoddig       using "&&&&&&&&", " ", lr_parametro.srrnom,        ASCII(09); # 33
     print  lr_parametro.msglog_atldat   using "yyyy-mm-dd", " ", l_hora_segundos4,         ASCII(09); # 34
     print  lr_parametro.tmp_transmissao clipped,                                           ASCII(09); # 35
     print  lr_parametro.rec_atdetpdat   using "yyyy-mm-dd", " ", l_hora_segundos5,         ASCII(09); # 36
     print  lr_parametro.tmp_qrurec,                                                        ASCII(09); # 37
     print  lr_parametro.dis_rec_soc_srv using "<<<<<<<<&",                                 ASCII(09); # 38
     print  lr_parametro.recbrrnom       clipped,                                           ASCII(09); # 39
     print  lr_parametro.rec_coord       clipped,                                           ASCII(09); # 40
     print  lr_parametro.rec_end         clipped,                                           ASCII(09); # 41
     print  lr_parametro.ini_atdetpdat   using "yyyy-mm-dd", " ", l_hora_segundos6,         ASCII(09); # 42
     print  lr_parametro.tmp_qruini      clipped,                                           ASCII(09); # 43
     print  lr_parametro.tmp_espseg      clipped,                                           ASCII(09); # 44
     print  lr_parametro.resultado       clipped,                                           ASCII(09); # 45
     print  lr_parametro.tmp_difprev     clipped,                                           ASCII(09); # 46
     print  lr_parametro.dis_ini_soc_srv using "<<<<<<<<&",                                 ASCII(09); # 47
     print  lr_parametro.inibrrnom       clipped,                                           ASCII(09); # 48
     print  lr_parametro.ini_coord       clipped,                                           ASCII(09); # 49
     print  lr_parametro.ini_end         clipped,                                           ASCII(09); # 50
     print  lr_parametro.fim_atdetpdat   using "yyyy-mm-dd", " ", l_hora_segundos7,         ASCII(09); # 51
     print  lr_parametro.tmp_qrufim      clipped,                                           ASCII(09); # 52
     print  lr_parametro.tmp_totsrv      clipped,                                           ASCII(09); # 53
     print  lr_parametro.dis_fim_soc_srv using "<<<<<<<<&",                                 ASCII(09); # 54
     print  lr_parametro.fimbrrnom       clipped,                                           ASCII(09); # 55
     print  lr_parametro.fim_coord       clipped,                                           ASCII(09); # 56
     print  lr_parametro.fim_end         clipped,                                           ASCII(09); # 57
     print  lr_parametro.dis_fim_soc_qti using "<<<<<<<<&",                                 ASCII(09); # 58
     print  lr_parametro.mdtcod,                                                            ASCII(09); # 59
     print  lr_parametro.mdtctrcod,                                                         ASCII(09); # 60

            let l_texto = ""

            if  lr_parametro.tmp_espseg > l_tmp_zero then
                if  lr_parametro.tmp_espseg > l_tmp_zero and  lr_parametro.tmp_espseg <= l_tmp_15 then
                    let l_texto = "ATE 15 min"
                else
                    if  lr_parametro.tmp_espseg >= l_tmp_15 and  lr_parametro.tmp_espseg <= l_tmp_30 then
                        let l_texto = "ENTRE 15 e 30 min"
                    else
                        if  lr_parametro.tmp_espseg >= l_tmp_30 and  lr_parametro.tmp_espseg <= l_tmp_45 then
                            let l_texto = "ENTRE 30 e 45 min"
                        else
                            if  lr_parametro.tmp_espseg >= l_tmp_45 and  lr_parametro.tmp_espseg < l_tmp_60 then
                                let l_texto = "ENTRE 45 e 60 min"
                            else
                                let l_texto = "MAIS DE 60 min"
                            end if
                        end if
                    end if
                end if
            end if

            print l_texto #61

end report

function bdbsr105_end_botao(lr_param)

   define lr_param record
          lclltt   like datmmdtmvt.lclltt,
          lcllgt   like datmmdtmvt.lcllgt
          end record

   define l_end    record
          msg      char(40),
          cid      char(40),
          brr      char(40),
          end      char(40)
          end record

   define l_coord    char(30),
          l_endereco char(100),
          l_local    like datkfxolcl.c24fxolcldes,
          l_lim      decimal(8,6),
          l_dist     decimal(8,6),
          l_lclltt   like datmmdtmvt.lclltt,
          l_lcllgt   like datmmdtmvt.lcllgt,
          l_tempo    datetime hour to second,
          l_i        smallint

   initialize l_end.* to null
   let l_endereco = null
   let l_local    = null
   let l_lim      = 0
   let l_dist     = 0
   let l_i        = 0
   let l_lclltt   = null
   let l_lcllgt   = null
   let l_tempo    = null

   let l_coord = lr_param.lclltt," e ", lr_param.lcllgt

   if lr_param.lclltt = 0 or lr_param.lcllgt = 0 then
      return l_coord, l_endereco
   end if

   ## obter o limite da distancia parametrizado
   call cts40g23_busca_chv("PSOPAR_BDBSR105")
        returning l_lim

   let l_tempo = current

   #foreach cbdbsr105016 into l_local, l_lclltt, l_lcllgt

   for l_i = 1 to 7000 step 1

           if ma_datkfxolcl[l_i].lclltt is null and
              ma_datkfxolcl[l_i].lcllgt is null and
              ma_datkfxolcl[l_i].c24fxolcldes is null then
              #display 'Sai do for com ', l_i using "<&&&", ' registros lidos'
              exit for
           end if

           if ma_datkfxolcl[l_i].lclltt is null or
              ma_datkfxolcl[l_i].lcllgt is null or
              ma_datkfxolcl[l_i].c24fxolcldes is null then
              #let l_i = l_i + 1
              continue for
           end if
           ## calcula a distancia entre local fixo e local do botao
           let l_dist = 0
           call cts18g00(lr_param.lclltt, lr_param.lcllgt,
                         ma_datkfxolcl[l_i].lclltt, ma_datkfxolcl[l_i].lcllgt)
                returning l_dist

           ## Se o botao estava proximo do local fixo, assumir o local fixo
           if l_dist <= l_lim then
              let l_endereco  = ma_datkfxolcl[l_i].c24fxolcldes
              #exit foreach
              exit for
           end if
           #let l_i = l_i + 1
   end for
   #end foreach

   let l_tempo = current

   ## Assumir o endereco do botao

   if l_endereco is null then

      #BURINI # Verifica ambiente de ROTERIZACAO
      #BURINI if ctx25g05_rota_ativa() then
      #BURINI    let l_tempo = current
      #BURINI
      #BURINI    call ctx25g01(lr_param.lclltt, lr_param.lcllgt,"B")
      #BURINI         returning l_end.*
      #BURINI
      #BURINI    if l_end.end is null then
      #BURINI       let l_tempo = current
      #BURINI
      #BURINI       call ctn44c02(lr_param.lclltt, lr_param.lcllgt)
      #BURINI         returning l_end.*
      #BURINI
      #BURINI       let l_tempo = current
      #BURINI    else
      #BURINI       let l_tempo = current
      #BURINI    end if
      #BURINI
      #BURINI else
         let l_tempo = current

         call ctn44c02(lr_param.lclltt, lr_param.lcllgt)
              returning l_end.*

         let l_tempo = current

      #BURINI end if

      let l_endereco = l_end.end

   else
     let l_tempo = current
   end if

   return l_coord, l_endereco

end function

function trim()
end function

#-------------------------------------#
report bdbsr105_relatorio_txt(lr_parametro)
#-------------------------------------#

  define lr_parametro       record
         ciaempcod          like datmservico.ciaempcod, # 1
         succod             like datrligapol.succod,    # 2
         ramcod             like datrligapol.ramcod,    # 3
         aplnumdig          like datrligapol.aplnumdig, # 4
         itmnumdig          like datrligapol.itmnumdig, # 5
         nom	 	            like datmservico.nom,       # 6 Nome Padrao
         #segnom            like gsakseg.segnom,        # 6
         vclmrccod  	      like agbkmarca.vclmrccod,   # 7
         vclmrcnom  	      like agbkmarca.vclmrcnom,   # 8
         vcllicnum          like datmservico.vcllicnum, # 9
         vclanomdl          like datmservico.vclanomdl, # 10
         c24astcod          like datmligacao.c24astcod, # 11
         c24astdes          like datkassunto.c24astdes, # 12
         atdsrvorg          like datmservico.atdsrvorg, # 13
         atdsrvnum          like datmsrvacp.atdsrvnum,  # 14
         atdsrvano          like datmsrvacp.atdsrvano,  # 15
         ufdcod_sede        like datmlcl.ufdcod,        # 16
         cidnom_sede        like datmlcl.cidnom,        # 17
         ufdcod             like datmlcl.ufdcod,        # 18
         cidnom             like datmlcl.cidnom,        # 19
         brrnom             like datmlcl.brrnom,        # 20
         atddat             like datmservico.atddat,    # 21
         atdhor             like datmservico.atdhor,    # 22
         lib_atdetpdat      like datmsrvacp.atdetpdat,  # 23
         lib_atdetphor      like datmsrvacp.atdetphor,  # 24
         acn_atdetpdat      like datmsrvacp.atdetpdat,  # 25
         acn_atdetphor      like datmsrvacp.atdetphor,  # 26
         dis_soc_srv        integer,                    # 27
         pstcoddig          like dpaksocor.pstcoddig,   # 28
         nomgrr             like dpaksocor.nomgrr,      # 29
         atdvclsgl          like datkveiculo.atdvclsgl, # 30
         cpodes             like iddkdominio.cpodes,    # 31
         srrcoddig          like datmsrvacp.srrcoddig,  # 32
         srrnom             like datksrr.srrnom,        # 33
         msglog_atldat      like datmmdtlog.atldat,     # 34
         msglog_atlhor      like datmmdtlog.atlhor,     # 35
         rec_atdetpdat      like datmmdtmvt.caddat,     # 36
         rec_atdetphor      like datmmdtmvt.cadhor,     # 37
         dis_rec_soc_srv    integer,                    # 38
         rec_coord          char(30),                   # 39
         rec_end            char(100),                  # 40
         ini_atdetpdat      like datmmdtmvt.caddat,     # 41
         ini_atdetphor      like datmmdtmvt.cadhor,     # 42
         dis_ini_soc_srv    integer,                    # 43
         ini_coord          char(30),                   # 44
         ini_end            char(100),                  # 45
         fim_atdetpdat      like datmmdtmvt.caddat,     # 46
         fim_atdetphor      like datmmdtmvt.cadhor,     # 47
         dis_fim_soc_srv    integer,                    # 48
         fim_coord          char(30),                   # 49
         fim_end            char(100),                  # 50
         mdtcod             like datkveiculo.mdtcod,    # 51
         mdtctrcod          like datkmdt.mdtctrcod,     # 52
         tipo               char(10),                   # 53
         tmp_liberacao      char(20),                   # 54
         tmp_acionamento    char(20),                   # 55
         atdprvdat          like datmservico.atdprvdat, # 56
         tmp_transmissao    char(20),                   # 57
         tmp_qrurec         char(20),                   # 58
         tmp_qruini         char(20),                   # 59
         tmp_espseg         char(20),                   # 60
         tmp_qrufim         char(20),                   # 61
         tmp_totsrv         char(20),                   # 63
         dtahor_iniprev     char(19),                   # 64
         resultado          char(08),                   # 65
         tmp_difprev        char(20),                   # 66
         recbrrnom          char(40),                   # 67
         inibrrnom          char(40),                   # 68
         fimbrrnom          char(40),                   # 69
         dis_fim_soc_qti    integer,                    # 70
         ligdat             like datmservico.atddat,    # 71
         lighorinc          like datmservico.atdhor, # 72
         lighorfnl          like datmservico.atdlibhor, # 73
         lr_tmaabtldo interval hour(3) to second           # 74
  end record

  define l_hora_segundos1   datetime hour to second,
         l_hora_segundos2   datetime hour to second,
         l_hora_segundos3   datetime hour to second,
         l_hora_segundos4   datetime hour to second,
         l_hora_segundos5   datetime hour to second,
         l_hora_segundos6   datetime hour to second,
         l_hora_segundos7   datetime hour to second,
         l_tmp_zero         interval hour(06) to second,
         l_tmp_15           interval hour(06) to second,
         l_tmp_30           interval hour(06) to second,
         l_tmp_45           interval hour(06) to second,
         l_tmp_60           interval hour(06) to second,
         l_texto            char(15)

  output
    left margin    00
    right margin   00
    top margin     00
    bottom margin  00
    page length    01 

  format



  on every row
  
  
     let l_tmp_zero = "00:00:00"
     let l_tmp_15   = "00:15:00"
     let l_tmp_30   = "00:30:00"
     let l_tmp_45   = "00:45:00"
     let l_tmp_60   = "01:00:00"

     let l_hora_segundos1  = lr_parametro.atdhor
     let l_hora_segundos2  = lr_parametro.lib_atdetphor
     let l_hora_segundos3  = lr_parametro.acn_atdetphor
     let l_hora_segundos4  = lr_parametro.msglog_atlhor
     let l_hora_segundos5  = lr_parametro.rec_atdetphor
     let l_hora_segundos6  = lr_parametro.ini_atdetphor
     let l_hora_segundos7  = lr_parametro.fim_atdetphor

     print  lr_parametro.ciaempcod,  ASCII(09); #1


     if lr_parametro.succod is null or lr_parametro.succod = "" then
         print "NAO CADASTRADO", ASCII(09);
     else
         print lr_parametro.succod, ASCII(09); #2
     end if

     if lr_parametro.ramcod is null or lr_parametro.ramcod = "" then
         print "NAO CADASTRADO", ASCII(09);
     else
         print lr_parametro.ramcod, ASCII(09);#3
     end if

     if lr_parametro.aplnumdig is null or lr_parametro.aplnumdig = "" then
         print "NAO CADASTRADO", ASCII(09);
     else
         print lr_parametro.aplnumdig, ASCII(09);#4
     end if

     if lr_parametro.itmnumdig is null or lr_parametro.itmnumdig = "" then
         print "NAO CADASTRADO", ASCII(09);
     else
         print lr_parametro.itmnumdig, ASCII(09);#5
     end if

    if lr_parametro.nom is null or lr_parametro.nom = "" then
         print "NAO CADASTRADO", ASCII(09);
     else
         print lr_parametro.nom, ASCII(09);#6
     end if

     if lr_parametro.vclmrccod is null or lr_parametro.vclmrccod = "" then
         print "NAO CADASTRADO", ASCII(09);
     else
         print lr_parametro.vclmrccod, ASCII(09);#7
     end if

     if lr_parametro.vclmrcnom is null or lr_parametro.vclmrcnom = "" then
         print "NAO CADASTRADO", ASCII(09);
     else
         print lr_parametro.vclmrcnom, ASCII(09);#8
     end if

     if lr_parametro.vcllicnum is null or lr_parametro.vcllicnum = "" then
         print "NAO CADASTRADO", ASCII(09);
     else
         print lr_parametro.vcllicnum, ASCII(09);#9
     end if

     if lr_parametro.vclanomdl is null or lr_parametro.vclanomdl = "" then
     	print "NAO CADASTRADO", ASCII(09);
     else
     print lr_parametro.vclanomdl, ASCII(09);#10
     end if

     if lr_parametro.c24astcod is null or lr_parametro.c24astcod = "" then
     	print "NAO CADASTRADO", ASCII(09);
     else
     print lr_parametro.c24astcod, ASCII(09);#11
     end if

     if lr_parametro.c24astdes is null or lr_parametro.c24astdes = "" then
     	print "NAO CADASTRADO", ASCII(09);
     else
     print lr_parametro.c24astdes, ASCII(09);#12
     end if

     print  lr_parametro.atdsrvorg       using "&&&&&",                                     ASCII(09); #13
     print  lr_parametro.atdsrvnum       using "&&&&&&&", "-",                              
            lr_parametro.atdsrvano       using "&&",                                        ASCII(09); # 14
     print  lr_parametro.acn_atdetpdat   using "yyyy-mm-dd",                                ASCII(09); # 15
     print  lr_parametro.tipo            clipped,                                           ASCII(09); # 16
     print  lr_parametro.ufdcod_sede     clipped,                                           ASCII(09); # 17
     print  lr_parametro.cidnom_sede     clipped,                                           ASCII(09); # 18
     print  lr_parametro.ufdcod          clipped,                                           ASCII(09); # 19
     print  lr_parametro.cidnom          clipped,                                           ASCII(09); # 20
     print  lr_parametro.brrnom          clipped,                                           ASCII(09); # 21
     print  lr_parametro.ligdat          using "yyyy-mm-dd", " ", lr_parametro.lighorinc,   ASCII(09); # 72
     print  lr_parametro.ligdat          using "yyyy-mm-dd", " ", lr_parametro.lighorfnl,   ASCII(09); # 73  
     print  lr_parametro.lr_tmaabtldo,                                                      ASCII(09); # 74   
     print  lr_parametro.atddat          using "yyyy-mm-dd", " ", l_hora_segundos1,         ASCII(09); # 22
     print  lr_parametro.lib_atdetpdat   using "yyyy-mm-dd", " ", l_hora_segundos2,         ASCII(09); # 23
     print  lr_parametro.tmp_liberacao   clipped,                                           ASCII(09); # 24
     print  lr_parametro.acn_atdetpdat   using "yyyy-mm-dd", " ", l_hora_segundos3,         ASCII(09); # 25
     print  lr_parametro.tmp_acionamento clipped,                                           ASCII(09); # 26
     print  lr_parametro.dtahor_iniprev  clipped,                                           ASCII(09); # 27
     print  lr_parametro.atdprvdat,                                                         ASCII(09); # 28
     print  lr_parametro.dis_soc_srv     using "<<<<<<<<&",                                 ASCII(09); # 29
     print  lr_parametro.pstcoddig       using "&&&&&&", " ", lr_parametro.nomgrr,          ASCII(09); # 30
     print  lr_parametro.atdvclsgl       clipped,                                           ASCII(09); # 31
     print  lr_parametro.cpodes          clipped,                                           ASCII(09); # 32
     print  lr_parametro.srrcoddig       using "&&&&&&&&", " ", lr_parametro.srrnom,        ASCII(09); # 33
     print  lr_parametro.msglog_atldat   using "yyyy-mm-dd", " ", l_hora_segundos4,         ASCII(09); # 34
     print  lr_parametro.tmp_transmissao clipped,                                           ASCII(09); # 35
     print  lr_parametro.rec_atdetpdat   using "yyyy-mm-dd", " ", l_hora_segundos5,         ASCII(09); # 36
     print  lr_parametro.tmp_qrurec,                                                        ASCII(09); # 37
     print  lr_parametro.dis_rec_soc_srv using "<<<<<<<<&",                                 ASCII(09); # 38
     print  lr_parametro.recbrrnom       clipped,                                           ASCII(09); # 39
     print  lr_parametro.rec_coord       clipped,                                           ASCII(09); # 40
     print  lr_parametro.rec_end         clipped,                                           ASCII(09); # 41
     print  lr_parametro.ini_atdetpdat   using "yyyy-mm-dd", " ", l_hora_segundos6,         ASCII(09); # 42
     print  lr_parametro.tmp_qruini      clipped,                                           ASCII(09); # 43
     print  lr_parametro.tmp_espseg      clipped,                                           ASCII(09); # 44
     print  lr_parametro.resultado       clipped,                                           ASCII(09); # 45
     print  lr_parametro.tmp_difprev     clipped,                                           ASCII(09); # 46
     print  lr_parametro.dis_ini_soc_srv using "<<<<<<<<&",                                 ASCII(09); # 47
     print  lr_parametro.inibrrnom       clipped,                                           ASCII(09); # 48
     print  lr_parametro.ini_coord       clipped,                                           ASCII(09); # 49
     print  lr_parametro.ini_end         clipped,                                           ASCII(09); # 50
     print  lr_parametro.fim_atdetpdat   using "yyyy-mm-dd", " ", l_hora_segundos7,         ASCII(09); # 51
     print  lr_parametro.tmp_qrufim      clipped,                                           ASCII(09); # 52
     print  lr_parametro.tmp_totsrv      clipped,                                           ASCII(09); # 53
     print  lr_parametro.dis_fim_soc_srv using "<<<<<<<<&",                                 ASCII(09); # 54
     print  lr_parametro.fimbrrnom       clipped,                                           ASCII(09); # 55
     print  lr_parametro.fim_coord       clipped,                                           ASCII(09); # 56
     print  lr_parametro.fim_end         clipped,                                           ASCII(09); # 57
     print  lr_parametro.dis_fim_soc_qti using "<<<<<<<<&",                                 ASCII(09); # 58
     print  lr_parametro.mdtcod,                                                            ASCII(09); # 59
     print  lr_parametro.mdtctrcod,                                                         ASCII(09); # 60

            let l_texto = ""

            if  lr_parametro.tmp_espseg > l_tmp_zero then
                if  lr_parametro.tmp_espseg > l_tmp_zero and  lr_parametro.tmp_espseg <= l_tmp_15 then
                    let l_texto = "ATE 15 min"
                else
                    if  lr_parametro.tmp_espseg >= l_tmp_15 and  lr_parametro.tmp_espseg <= l_tmp_30 then
                        let l_texto = "ENTRE 15 e 30 min"
                    else
                        if  lr_parametro.tmp_espseg >= l_tmp_30 and  lr_parametro.tmp_espseg <= l_tmp_45 then
                            let l_texto = "ENTRE 30 e 45 min"
                        else
                            if  lr_parametro.tmp_espseg >= l_tmp_45 and  lr_parametro.tmp_espseg < l_tmp_60 then
                                let l_texto = "ENTRE 45 e 60 min"
                            else
                                let l_texto = "MAIS DE 60 min"
                            end if
                        end if
                    end if
                end if
            end if

            print l_texto

end report