#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: CTS35M00                                                   #
# ANALISTA RESP..: CARLOS ANTONIO RUIZ/RAJI JAHCHAN                           #
# PSI/OSF........: 193429                                                     #
#                  CARGA DA CONTINGENCIA.                                     #
# ........................................................................... #
# DESENVOLVIMENTO: ALEXANDRE JAHCHAN                                          #
# LIBERACAO......: 22/02/2005                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 23/09/06   Ligia Mattge  PSI 202720   Implementar grupo/cartao saude        #
#-----------------------------------------------------------------------------#
# 17/05/07   Ruiz                       Gravar nulo no campo ZONA quando      #
#                                       estiver com branco.                   #
#-----------------------------------------------------------------------------#
# 28/05/07   Ruiz          PSI 209007   Adaptacoes para contingencia da Azul, #
#                                       inclusao da ciaempcod.                #
#                                                                             #
# 30/05/08   Amilton,Meta               Inclus�o do Assunto K21 com a mesma   #
#                                       regra do K15                          #
#-----------------------------------------------------------------------------#
# 30/12/2008 Priscila                      Exibir mensagem de erro retornada  #
#                                          por ctd25g00                       #
#-----------------------------------------------------------------------------#
# 22/03/2010 Beatriz Araujo PSI219444    Notificar o RE de servicos agendados,#
#                                        cancelados na contingencia           #
#-----------------------------------------------------------------------------#
# 24/05/2011 Marcos Goes                Inclusao da carga de contingencia das #
#                                       apolices ITAU.                        #
#-----------------------------------------------------------------------------#
# 29/10/2013  PSI-2013-23297            Altera��o da utiliza��o do sendmail   #
#-----------------------------------------------------------------------------#
# 22/04/2014  PSI-2013-07142/EV         Inclusao de servicos empresa 43 SAPS  #
###############################################################################



globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/figrc012.4gl"

database porto

  define m_arq_proc1   char(25),
         m_arq_proc2   char(25),
         m_arq_proc3   char(25),
         m_arq_proc4   char(25),
         m_cont_proc1  smallint,
         m_cont_proc2  smallint,
         m_cont_proc3  smallint,
         m_cont_proc4  smallint,
         m_crtsaunum   like datrligsau.crtnum,
         m_bnfnum      like datrligsau.bnfnum,
         m_status      smallint,
         m_msg         char(50),
         m_succod      like datksegsau.succod,
         m_ramcod      like datksegsau.ramcod,
         m_aplnumdig   like datksegsau.aplnumdig,
         m_versao      integer
 define msg      record
        linha1   char(40),
        linha2   char(40),
        linha3   char(40),
        linha4   char(40),
        confirma char(1)
 end record

{main

   call fun_dba_abre_banco("CT24HS")
   set lock mode to wait 10
   set isolation to dirty read

   let g_issk.funmat = 601566
   let g_issk.empcod = 1
   let g_issk.usrtip = "F"
   call startlog("cts35m00.log")
   call cts35m00()

 end main
}
#=============================#
 function cts35m00_prepare()
#=============================#

  define l_cmd char(5000)

  --[ Tabela Interface de Servico ]--

 #@INICIALIZADA PELA COMPILADA-NAO APAGAR@#


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let     l_cmd  =  null

  let l_cmd  =  null

  if m_versao = 0 then
     let l_cmd = "select seqreg "
                ," ,seqregcnt "
                ," ,atdsrvorg "
                ," ,atdsrvnum "
                ," ,atdsrvano "
                ," ,srvtipabvdes "
                ," ,atdnom "
                ," ,funmat "
                ," ,asitipabvdes "
                ," ,c24solnom "
                ," ,vcldes "
                ," ,vclanomdl "
                ," ,vclcor "
                ," ,vcllicnum "
                ," ,vclcamtip "
                ," ,vclcrgflg "
                ," ,vclcrgpso "
                ," ,atddfttxt "
                ," ,segnom "
                ," ,aplnumdig "
                ," ,cpfnum "
                ," ,ocrufdcod "
                ," ,ocrcidnom "
                ," ,ocrbrrnom "
                ," ,ocrlgdnom "
                ," ,ocrendcmp "
                ," ,ocrlclcttnom "
                ," ,ocrlcltelnum "
                ," ,ocrlclrefptotxt "
                ," ,dsttipflg "
                ," ,dstufdcod "
                ," ,dstcidnom "
                ," ,dstbrrnom "
                ," ,dstlgdnom "
                ," ,rmcacpflg "
                ," ,obstxt "
                ," ,srrcoddig "
                ," ,srrabvnom "
                ," ,atdvclsgl "
                ," ,atdprscod "
                ," ,nomgrr "
                ," ,atddat "
                ," ,atdhor "
                ," ,acndat "
                ," ,acnhor "
                ," ,acnprv "
                ," ,c24openom "
                ," ,c24opemat "
                ," ,pasnom1 "
                ," ,pasida1 "
                ," ,pasnom2 "
                ," ,pasida2 "
                ," ,pasnom3 "
                ," ,pasida3 "
                ," ,pasnom4 "
                ," ,pasida4 "
                ," ,pasnom5 "
                ," ,pasida5 "
                ," ,atldat "
                ," ,atlhor "
                ," ,atlmat "
                ," ,atlnom "
                ," ,cnlflg "
                ," ,cnldat "
                ," ,cnlhor "
                ," ,cnlmat "
                ," ,cnlnom "
                ," ,socntzcod "
                ," ,c24astcod "
                ," ,atdorgsrvnum "
                ," ,atdorgsrvano "
                ," ,srvtip "
                ," ,acnifmflg "
                ," ,dstsrvnum "
                ," ,dstsrvano "
                ," ,prcflg "
                ," ,ramcod "
                ," ,succod "
                ," ,itmnumdig "
                ," ,ocrlcldddcod "
                ," ,cpfdig "
                ," ,cgcord "
                ," ,ocrendzoncod "
                ," ,dstendzoncod "
                ," ,sindat       "
                ," ,sinhor       "
                ," ,bocnum       "
                ," ,boclcldes    "
                ," ,sinavstip    "
                ," ,vclchscod    "
                ," ,obscmptxt    "
                ," ,crtsaunum    "
                ," ,ciaempcod    "
                ," ,atdnum       "
           ,"  from datmcntsrv "
          ,"  where prcflg = 'N' "
          ,"  order by atdprscod, seqreg " #Priorizar carga dos servicos nao acionados
  else
       let l_cmd = "select seqreg "
                ," ,seqregcnt "
                ," ,atdsrvorg "
                ," ,atdsrvnum "
                ," ,atdsrvano "
                ," ,srvtipabvdes "
                ," ,atdnom "
                ," ,funmat "
                ," ,asitipabvdes "
                ," ,c24solnom "
                ," ,vcldes "
                ," ,vclanomdl "
                ," ,vclcor "
                ," ,vcllicnum "
                ," ,vclcamtip "
                ," ,vclcrgflg "
                ," ,vclcrgpso "
                ," ,atddfttxt "
                ," ,segnom "
                ," ,aplnumdig "
                ," ,cpfnum "
                ," ,ocrufdcod "
                ," ,ocrcidnom "
                ," ,ocrbrrnom "
                ," ,ocrlgdnom "
                ," ,ocrendcmp "
                ," ,ocrlclcttnom "
                ," ,ocrlcltelnum "
                ," ,ocrlclrefptotxt "
                ," ,dsttipflg "
                ," ,dstufdcod "
                ," ,dstcidnom "
                ," ,dstbrrnom "
                ," ,dstlgdnom "
                ," ,rmcacpflg "
                ," ,obstxt "
                ," ,srrcoddig "
                ," ,srrabvnom "
                ," ,atdvclsgl "
                ," ,atdprscod "
                ," ,nomgrr "
                ," ,atddat "
                ," ,atdhor "
                ," ,acndat "
                ," ,acnhor "
                ," ,acnprv "
                ," ,c24openom "
                ," ,c24opemat "
                ," ,pasnom1 "
                ," ,pasida1 "
                ," ,pasnom2 "
                ," ,pasida2 "
                ," ,pasnom3 "
                ," ,pasida3 "
                ," ,pasnom4 "
                ," ,pasida4 "
                ," ,pasnom5 "
                ," ,pasida5 "
                ," ,atldat "
                ," ,atlhor "
                ," ,atlmat "
                ," ,atlnom "
                ," ,cnlflg "
                ," ,cnldat "
                ," ,cnlhor "
                ," ,cnlmat "
                ," ,cnlnom "
                ," ,socntzcod "
                ," ,c24astcod "
                ," ,atdorgsrvnum "
                ," ,atdorgsrvano "
                ," ,srvtip "
                ," ,acnifmflg "
                ," ,dstsrvnum "
                ," ,dstsrvano "
                ," ,prcflg "
                ," ,ramcod "
                ," ,succod "
                ," ,itmnumdig "
                ," ,ocrlcldddcod "
                ," ,cpfdig "
                ," ,cgcord "
                ," ,ocrendzoncod "
                ," ,dstendzoncod "
                ," ,sindat       "
                ," ,sinhor       "
                ," ,bocnum       "
                ," ,boclcldes    "
                ," ,sinavstip    "
                ," ,vclchscod    "
                ," ,obscmptxt    "
                ," ,crtsaunum    "
                ," ,ciaempcod    "
                ," ,atdnum       "
                ," ,ocrlcllttnum "
                ," ,ocrlcllgnnum "
                ," ,ocrlclidxtipcod "
                ," ,dstlcllttnum "
                ," ,dstlcllgnnum "
                ," ,dstlclidxtipcod "
                ," ,vclmoddigcod "
                ," ,empcod "
                ," ,h24ctloprempcod "
                ," ,usrtipcod "
           ,"  from datmcntsrv "
          ,"  where prcflg = 'N' "
          ,"  order by atdprscod, seqreg " #Priorizar carga dos servicos nao acionados



  end if
  if cty42g00_online() then
  	 let l_cmd = cty42g00_prepara(m_versao)
  end if

  prepare p_cts35m00_001 from l_cmd
  declare c_cts35m00_001 cursor with hold for p_cts35m00_001


  --[ Tabela Interface de Veiculo ]--
  let l_cmd = "select seqreg "
                  ," ,atdvclsgl "
                  ," ,c24atvcod "
                  ," ,prcflg "
                  ," ,seqregcnt "
                  ," ,atdsrvnum "
                  ," ,atdsrvano "
                  ," ,gpsufdcod "
                  ," ,gpscidnom "
                  ," ,gpsbrrnom "
                  ," ,gpsendzon "
                  ," ,gpslclltt "
                  ," ,gpslcllgt "
                  ," ,qthufdcod "
                  ," ,qthcidnom "
                  ," ,qthbrrnom "
                  ," ,qthendzon "
                  ," ,qthlclltt "
                  ," ,qthlcllgt "
                  ," ,qtiufdcod "
                  ," ,qticidnom "
                  ," ,qtibrrnom "
                  ," ,qtiendzon "
                  ," ,qtilclltt "
                  ," ,qtilcllgt "
              ," from datmcntsttvcl "

  prepare p_cts35m00_002 from l_cmd
  declare c_cts35m00_002 cursor with hold for p_cts35m00_002

  --[ Tabela de Veiculo ]--
  let l_cmd = " select socvclcod from datkveiculo "
            , "  where atdvclsgl = ? "

  prepare p_cts35m00_003 from l_cmd
  declare c_cts35m00_003 cursor for p_cts35m00_003

  --[ Atualiza Conclusao de Servico ]--
  let l_cmd = "update datmservico   "
               ," set atdprscod = ? "
                  ," ,socvclcod = ? "
                  ," ,srrcoddig = ? "
                  ," ,c24nomctt = ? "
                  ," ,atdfnlhor = ? "
                  ," ,c24opemat = ? "
                  ," ,cnldat    = ? "
                  ," ,atdcstvlr = '' "
                  ," ,atdprvdat = '' "
                  ," ,atdfnlflg = 'S'"
                  ," where atdsrvnum = ?  "
                  ,"   and atdsrvano = ?  "

  prepare p_cts35m00_004 from l_cmd

  let l_cmd = " select dstsrvnum, ",
                     " dstsrvano ",
                " from datmcntsrv ",
               " where seqreg = (select max(seqreg) ",
                                 " from datmcntsrv ",
                                " where seqregcnt = ?) "

  prepare p_cts35m00_005 from l_cmd
  declare c_cts35m00_004 cursor with hold for p_cts35m00_005

  let l_cmd = " update datmfrtpos set ",
                    " (ufdcod, ",
                    "  cidnom, ",
                    "  brrnom, ",
                    "  endzon, ",
                    "  lclltt, ",
                    "  lcllgt, ",
                    "  atldat, ",
                    "  atlhor) = ",
                    " (?,?,?,?,?,?,today,current hour to second) ",
              "  where socvclcod = ? ",
                 " and socvcllcltip = 3 "

  prepare p_cts35m00_006 from l_cmd

  let l_cmd = " select mdtmsgnum, ",
                     " mdtmsgorgcod, ",
                     " mdtcod, ",
                     " mdtmsgstt, ",
                     " mdtmsgavstip, ",
                     " mdtmsgtxtseq, ",
                     " mdtmsgtxt, ",
                     " atdsrvnum, ",
                     " atdsrvano, ",
                     " seqregcnt, ",
                     " prcflg, ",
                     " novmsgflg ",
                " from datmcntmsgctr ",
               " where prcflg = 'N' "

  prepare p_cts35m00_007 from l_cmd
  declare c_cts35m00_005 cursor with hold for p_cts35m00_007

  let l_cmd = " insert into datmmdtmsg ",
                         " (mdtmsgnum, ",
                          " mdtmsgorgcod, ",
                          " mdtcod, ",
                          " mdtmsgstt, ",
                          " mdtmsgavstip) ",
                   " values(0,?,?,?,?) "

  prepare p_cts35m00_008 from l_cmd

  let l_cmd = " insert into datmmdtmsgtxt ",
                         " (mdtmsgnum, ",
                          " mdtmsgtxtseq, ",
                          " mdtmsgtxt) ",
                   " values(?,?,?) "

  prepare p_cts35m00_009 from l_cmd

  let l_cmd = " insert into datmmdtsrv ",
                         " (mdtmsgnum, ",
                          " atdsrvnum, ",
                          " atdsrvano) ",
                   " values(?,?,?) "

  prepare p_cts35m00_010 from l_cmd

  let l_cmd = " select datmcntlogctr.mdtmsgnum, ",
                     " datmcntlogctr.mdtmsgstt, ",
                     " datmcntlogctr.atldat, ",
                     " datmcntlogctr.atlhor, ",
                     " datmcntlogctr.atlemp, ",
                     " datmcntlogctr.atlmat, ",
                     " datmcntlogctr.atlusrtip,",
                     " datmcntmsgctr.atdsrvnum, ",
                     " datmcntmsgctr.atdsrvano, ",
                     " datmcntmsgctr.seqregcnt, ",
                     " datmcntmsgctr.novmsgflg ",
                " from datmcntlogctr, ",
                     " outer datmcntmsgctr ",
               " where datmcntlogctr.mdtmsgnum = datmcntmsgctr.mdtmsgnum  ",
               "   and datmcntlogctr.prcflg    = 'N' "

  prepare p_cts35m00_011 from l_cmd
  declare c_cts35m00_006 cursor with hold for p_cts35m00_011

  let l_cmd = " select max(mdtlogseq) ",
                " from datmmdtlog ",
               " where mdtmsgnum = ? "

  prepare p_cts35m00_012 from l_cmd
  declare c_cts35m00_007 cursor with hold for p_cts35m00_012

  let l_cmd = " insert into datmmdtlog ",
                         " (mdtmsgnum, ",
                          " mdtlogseq, ",
                          " mdtmsgstt, ",
                          " atldat, ",
                          " atlhor, ",
                          " atlemp, ",
                          " atlmat, ",
                          " atlusrtip) ",
                   " values(?,?,?,?,?,?,?,?) "

  prepare p_cts35m00_013 from l_cmd

  let l_cmd = " update datmmdtmsg set ",
                    " (mdtmsgstt) = (?) ",
               " where mdtmsgnum = ? "

  prepare p_cts35m00_014 from l_cmd

  let l_cmd = " select relpamtxt ",
                " from igbmparam ",
               " where relsgl = 'CTS35M00' "

  prepare p_cts35m00_015 from l_cmd
  declare c_cts35m00_008 cursor for p_cts35m00_015

  let l_cmd = " update datmcntmsgctr set ",
                     " prcflg = 'S' ",
               " where mdtmsgnum = ? "

  prepare p_cts35m00_016 from l_cmd

  let l_cmd = " select vigfnl ",
                " from rsdmdocto ",
               " where prporg = ? ",
                 " and prpnumdig = ? "

  prepare p_cts35m00_017 from l_cmd
  declare c_cts35m00_009 cursor for p_cts35m00_017

  let l_cmd = " update datmservico ",
                 " set atdfnlflg = 'S' ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare p_cts35m00_018 from l_cmd

  let l_cmd = " update datmcntsrv ",
                 " set prcflg = 'S' ",
               " where seqreg = ? "

  prepare p_cts35m00_019 from l_cmd

  let l_cmd = " select cpocod ",
                " from iddkdominio ",
               " where cponom = 'vclcorcod' ",
                 " and cpodes = ? "

  prepare p_cts35m00_020 from l_cmd
  declare c_cts35m00_010 cursor with hold for p_cts35m00_020

  let l_cmd = " insert into datrservapol ",
                         " (atdsrvnum, ",
                          " atdsrvano, ",
                          " succod, ",
                          " ramcod, ",
                          " aplnumdig, ",
                          " itmnumdig, ",
                          " edsnumref) ",
                   " values(?,?,?,?,?,?,?) "

  prepare p_cts35m00_021 from l_cmd

  let l_cmd = " insert into datmservicocmp ",
                         " (atdsrvnum, ",
                          " atdsrvano, ",
                          " rmcacpflg, ",
                          " vclcamtip, ",
                          " vclcrcdsc, ",
                          " vclcrgflg, ",
                          " vclcrgpso, ",
                          " sindat, ",
                          " sinhor) ",
                   " values(?,?,?,?,null,?,?, ",
                          " today,current hour to minute) "

  prepare p_cts35m00_022 from l_cmd

  let l_cmd = " insert into datmsrvre ",
                         " (atdsrvnum, ",
                          " atdsrvano, ",
                          " lclrsccod, ",
                          " orrdat, ",
                          " orrhor, ",
                          " socntzcod, ",
                          " atdsrvretflg, ",
                          " atdorgsrvnum, ",
                          " atdorgsrvano, ",
                          " srvretmtvcod) ",
               " values(?,?,null,today,'00:00', ",
                       " ?,'N',?,?,null) "

  prepare p_cts35m00_023 from l_cmd

  let l_cmd = " insert into datmassistpassag ",
                         " (atdsrvnum, ",
                          " atdsrvano, ",
                          " bagflg, ",
                          " refatdsrvnum, ",
                          " refatdsrvano, ",
                          " asimtvcod, ",
                          " atddmccidnom, ",
                          " atddmcufdcod, ",
                          " atddstcidnom, ",
                          " atddstufdcod, ",
                          " trppfrdat, ",
                          " trppfrhor) ",
                   " values(?,?,'N',null,null,null, ",
                          " null,null,null,null,null,null) "

  prepare p_cts35m00_024 from l_cmd

  let l_cmd = " select max(passeq) ",
                " from datmpassageiro ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare p_cts35m00_025 from l_cmd
  declare c_cts35m00_011 cursor for p_cts35m00_025

  let l_cmd = " insert into datmpassageiro ",
                         " (atdsrvnum, ",
                          " atdsrvano, ",
                          " passeq, ",
                          " pasnom, ",
                          " pasidd) ",
                   " values(?,?,?,?,?) "

  prepare p_cts35m00_026 from l_cmd

  let l_cmd = " insert into datmlcl(atdsrvnum, ",
                                  " atdsrvano, ",
                                  " c24endtip, ",
                                  " lclidttxt, ",
                                  " lgdtip, ",
                                  " lgdnom, ",
                                  " lgdnum, ",
                                  " lclbrrnom, ",
                                  " brrnom, ",
                                  " cidnom, ",
                                  " ufdcod, ",
                                  " lclrefptotxt, ",
                                  " endzon, ",
                                  " lgdcep, ",
                                  " lgdcepcmp, ",
                                  " lclltt, ",
                                  " lcllgt, ",
                                  " dddcod, ",
                                  " lcltelnum, ",
                                  " lclcttnom, ",
                                  " c24lclpdrcod, ",
                                  " ofnnumdig, ",
                                  " endcmp) ",
                                  " values (?,?,?,?,?,?,?,?,?,?,?, ",
                                          " ?,?,?,?,?,?,?,?,?,?,?,?) "

  prepare p_cts35m00_027 from l_cmd

  let l_cmd = " update datmcntsrv ",
                " set (dstsrvnum, dstsrvano, prcflg)= (?,?,'S') ",
               " where seqreg = ? "

  prepare p_cts35m00_028 from l_cmd

  let l_cmd =  " select segnumdig ",
                 " from gsakseg ",
                " where cgccpfnum = ? ",
                  " and pestip = ? "

  prepare p_cts35m00_029 from l_cmd
  declare c_cts35m00_012 cursor for p_cts35m00_029

  let l_cmd = " select unique succod, ",
                            " aplnumdig ",
                       " from abbmdoc ",
                      " where abbmdoc.segnumdig = ? ",
                        " and abbmdoc.vigfnl >= today - 60 units day ",
                            " union ",
                     " select succod, ",
                            " aplnumdig ",
                       " from abamapol ",
                      " where abamapol.etpnumdig = ? ",
                        " and abamapol.vigfnl >= today - 60 units day "

  prepare p_cts35m00_030 from l_cmd
  declare c_cts35m00_013 cursor for p_cts35m00_030

  let l_cmd = " select aplstt, ",
                     " viginc, ",
                     " vigfnl ",
                " from abamapol ",
               " where succod = ? ",
                 " and aplnumdig = ? "

  prepare p_cts35m00_031 from l_cmd
  declare c_cts35m00_014 cursor for p_cts35m00_031

  let l_cmd = " select itmnumdig ",
                " from abbmdoc ",
               " where succod = ? ",
                 " and aplnumdig = ? "

  prepare p_cts35m00_032 from l_cmd
  declare c_cts35m00_015 cursor for p_cts35m00_032

  let l_cmd = " select itmsttatu ",
                " from abbmitem ",
               " where succod = ? ",
                 " and aplnumdig = ? ",
                 " and itmnumdig = ? "

  prepare p_cts35m00_033 from l_cmd
  declare c_cts35m00_016 cursor for p_cts35m00_033

  let l_cmd = " select rsdmdocto.prporg ",
                    " ,rsdmdocto.prpnumdig ",
                    " ,rsdmdocto.sgrorg ",
                    " ,rsdmdocto.sgrnumdig ",
                    " ,rsdmdocto.dctnumseq ",
                    " ,rsamseguro.succod ",
                    " ,rsamseguro.aplnumdig ",
                    " ,rsamseguro.ramcod ",
                " from rsdmdocto, rsamseguro ",
               " where rsdmdocto.segnumdig = ? and ",
                     " rsdmdocto.edsstt <> 'C' and ",
                     " rsamseguro.sgrorg = rsdmdocto.sgrorg and ",
                     " rsamseguro.sgrnumdig = rsdmdocto.sgrnumdig and ",
                     " rsamseguro.aplnumdig <> 0 ",
               " order by succod, aplnumdig, sgrnumdig "

  prepare p_cts35m00_034 from l_cmd
  declare c_cts35m00_017 cursor for p_cts35m00_034

  let l_cmd = " select abbmveic.succod ",
                    " ,abbmveic.aplnumdig ",
                    " ,abbmveic.itmnumdig ",
                    " ,max(abbmveic.dctnumseq) ",
                " from abbmveic ",
               " where abbmveic.vcllicnum = ? ",
               " group by succod, aplnumdig, itmnumdig "

  prepare p_cts35m00_035 from l_cmd
  declare c_cts35m00_018 cursor for p_cts35m00_035

  let l_cmd = " select 1 ",
                " from datmservico ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare p_cts35m00_036 from l_cmd
  declare c_cts35m00_019 cursor for p_cts35m00_036

  let l_cmd = " select count(*) ",
                " from datmcntsrv ",
               " where prcflg = 'N' ",
               "   and ciaempcod = '1' "

  prepare p_cts35m00_037 from l_cmd
  declare c_cts35m00_020 cursor for p_cts35m00_037

  let l_cmd = " update datmcntlogctr set ",
                     " prcflg = 'S' ",
                " where mdtmsgnum = ? "

  prepare p_cts35m00_038 from l_cmd

  let l_cmd = " select mdtmsgnum  ",
              "   from datmmdtsrv ",
              "  where mdtmsgnum = (select max(mdtmsgnum) ",
                                  "   from datmmdtsrv     ",
                                  "  where atdsrvnum = ?  ",
                                  "    and atdsrvano = ?) "
  prepare p_cts35m00_039 from l_cmd
  declare c_cts35m00_021 cursor with hold for p_cts35m00_039

  # TOTAL SEGUNDO PROCESSO
  let l_cmd = " select count(*) ",
                " from datmcntsttvcl "

  prepare p_cts35m00_040 from l_cmd
  declare c_cts35m00_022 cursor for p_cts35m00_040

  # TOTAL TERCEIRO PROCESSO
  let l_cmd = " select count(*) ",
                " from datmcntmsgctr ",
               " where prcflg = 'N' "

  prepare p_cts35m00_041 from l_cmd
  declare c_cts35m00_023 cursor for p_cts35m00_041

  # TOTAL QUARTO PROCESSO
  let l_cmd = " select count(*) ",
                " from datmcntlogctr, ",
                     " outer datmcntmsgctr ",
               " where datmcntlogctr.mdtmsgnum = datmcntmsgctr.mdtmsgnum  ",
               "   and datmcntlogctr.prcflg = 'N' "

  prepare p_cts35m00_042 from l_cmd
  declare c_cts35m00_024 cursor for p_cts35m00_042

  let l_cmd = " insert into datmsrvacp (atdsrvnum, ",
                                      " atdsrvano, ",
                                      " atdsrvseq, ",
                                      " atdetpcod, ",
                                      " atdetpdat, ",
                                      " atdetphor, ",
                                      " empcod, ",
                                      " funmat, ",
                                      " pstcoddig, ",
                                      " srrcoddig, ",
                                      " socvclcod, ",
                                      " c24nomctt) ",
                               " values(?,?,?,?,?,?,?,?,?,?,?,?) "

  prepare p_cts35m00_043 from l_cmd

  let l_cmd = " select max(atdsrvseq) ",
                " from datmsrvacp ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? "

  prepare p_cts35m00_044 from l_cmd
  declare c_cts35m00_025 cursor with hold for p_cts35m00_044

  let l_cmd = " delete from datmcntsttvcl "

  prepare p_cts35m00_045 from l_cmd

# atualiza com "E" de erro
  let l_cmd = " update datmcntmsgctr set ",
                     " prcflg = 'E' ",
               " where mdtmsgnum = ? "

  prepare p_cts35m00_046 from l_cmd

  ### PSI 202720
  let l_cmd = " insert into datrsrvsau ",
                         " (atdsrvnum, ",
                          " atdsrvano, ",
                          " succod, ",
                          " ramcod, ",
                          " aplnumdig, ",
                          " crtnum, ",
                          " bnfnum) ",
                   " values(?,?,?,?,?,?,?) "

  prepare p_cts35m00_047 from l_cmd

  let l_cmd = " select succod,       ",
              "        ramcod,       ",
              "        aplnumdig     ",
              "   from datksegsau    ",
              "  where crtsaunum = ? "

  prepare p_cts35m00_048 from l_cmd
  declare c_cts35m00_026 cursor for p_cts35m00_048

  let l_cmd = " update datkgeral set ",
              "      (grlinf,   ",
              "       atldat,   ",
              "       atlhor) = ",
              "       ('PROCESSADA',today,current hour to second) ",
              " where grlchv = 'PSOCNTCARGA'   ",
              "   and grlinf = 'NAO PROCESSADA' "
  prepare p_cts35m00_049 from l_cmd

  let l_cmd = " select count(*) ",
              " from datmcntsrv ",
              " where prcflg = 'N' ",
              "   and ciaempcod = '35' "   # Azul Seguros

  prepare p_cts35m00_050 from l_cmd
  declare c_cts35m00_027 cursor for p_cts35m00_050
  let l_cmd = " select grlinf    ",
            " from datkgeral   ",
            " where grlchv = ? "
  prepare pcts35m00056 from l_cmd
  declare ccts35m00056 cursor for pcts35m00056
  let l_cmd = " insert into datkgeral  ",
              "            (grlchv,    ",
              "             grlinf,    ",
              "             atldat,    ",
              "             atlhor,    ",
              "             atlemp,    ",
              "             atlmat)    ",
              " values(?,?,?,?,?,?)    "
  prepare pcts35m00057 from l_cmd
  let l_cmd = " update datkgeral  ",
              " set grlinf   = ?  ",
              " where grlchv = ?  "
  prepare pcts35m00058 from l_cmd
  let l_cmd = " delete from datkgeral  ",
              " where grlchv = ?       "
  prepare pcts35m00059 from l_cmd


  let l_cmd = "SELECT COUNT(*)      ",
              "FROM datmcntsrv      ",
              "WHERE prcflg = 'N'   ",
              "AND   ciaempcod = 84 "   # ITAU (Marcos Goes)
  prepare p_cts35m00_060 from l_cmd
  declare c_cts35m00_029 cursor for p_cts35m00_060

  let l_cmd = "SELECT COUNT(*)      ",
              "FROM datmcntsrv      ",
              "WHERE prcflg = 'N'   ",
              "AND   ciaempcod = 43 "   # SAPS (Celso Issamu)
  prepare p_cts35m00_061 from l_cmd
  declare c_cts35m00_031 cursor for p_cts35m00_061
  let l_cmd = " select a.funnom           "
             ,"       ,a.usrtip           "
             ,"       ,b.dptnom           "
             ," from isskfunc a           "
             ,"     ,isskdepto b          "
             ," where a.dptsgl = b.dptsgl "
             ,"   and a.empcod = ?        "
             ,"   and a.funmat = ?        "
  prepare p_cts35m00_062 from l_cmd
  declare c_cts35m00_032 cursor for p_cts35m00_062 # Humberto
  let l_cmd = " select cpodes    "
             ," from datkdominio "
             ," where cponom = 'cts35m00_email_rel' "
  prepare p_cts35m00_063 from l_cmd
  declare c_cts35m00_033 cursor for p_cts35m00_063
  let l_cmd = " update datkdominio                   "
             ,"   set (cpodes,atlult) = ('S',?)      "
             ,"  where cponom = 'carga_contingencia' "
  prepare p_cts35m00_064 from l_cmd
  let l_cmd = " update datkdominio                   "
             ,"   set (cpodes,atlult) = ('N',?)      "
             ,"  where cponom = 'carga_contingencia' "
  prepare p_cts35m00_065 from l_cmd

let l_cmd = " insert into datrligcgccpf ",
                          "(lignum,  ",
                          " cgccpfnum, ",
                          " cgcord, ",
                          " cgccpfdig )",
                          " values (?,?,?,?) "
  prepare p_cts35m00_066 from l_cmd


end function

#--------------------------------------------------#
function cts35m00_cria_temp()
#--------------------------------------------------#
 call cts35m00_drop_temp()
 whenever error continue
      create temp table cts35m00_temp(seqreg decimal(10,0))with no log
 whenever error stop
      if sqlca.sqlcode <> 0  then
         if sqlca.sqlcode = -310 or
            sqlca.sqlcode = -958 then
                call cts35m00_drop_temp()
         end if
         return false
      end if
      return true
end function
#------------------------------------------------------------------------------
function cts35m00_drop_temp()
#------------------------------------------------------------------------------
    whenever error continue
        drop table cts35m00_temp
    whenever error stop
    return
end function
#------------------------------------------------------------------------------
function cts35m00_prep_temp()
#------------------------------------------------------------------------------
    define w_ins char(100)
    let w_ins = 'insert into cts35m00_temp'
	     , ' values(?)'
    prepare p_insert from w_ins
end function
#---------------------------------------------------------------------------
function cts35m00_seleciona_temp()
#---------------------------------------------------------------------------
define l_comando char(200)
  let l_comando = " select a.c24astcod,       ",
                  "        count(*)           ",
                  " from datmcntsrv a ,       ",
                  "      cts35m00_temp b      ",
                  " where b.seqreg = a.seqreg ",
                  " group by 1                ",
                  " order by 1                "
  prepare pcts35m00_temp from l_comando
  declare ccts35m00_temp cursor for pcts35m00_temp
  return
end function

#-----------------#
function cts35m00()
#-----------------#

  define l_datmcntsrv    record
         seqreg          like datmcntsrv.seqreg,
         seqregcnt       like datmcntsrv.seqregcnt,
         atdsrvorg       like datmcntsrv.atdsrvorg,
         atdsrvnum       like datmcntsrv.atdsrvnum,
         atdsrvano       like datmcntsrv.atdsrvano,
         srvtipabvdes    like datmcntsrv.srvtipabvdes,
         atdnom          like datmcntsrv.atdnom,
         funmat          like datmcntsrv.funmat,
         asitipabvdes    like datmcntsrv.asitipabvdes,
         c24solnom       like datmcntsrv.c24solnom,
         vcldes          like datmcntsrv.vcldes,
         vclanomdl       like datmcntsrv.vclanomdl,
         vclcor          like datmcntsrv.vclcor,
         vcllicnum       like datmcntsrv.vcllicnum,
         vclcamtip       like datmcntsrv.vclcamtip,
         vclcrgflg       like datmcntsrv.vclcrgflg,
         vclcrgpso       like datmcntsrv.vclcrgpso,
         atddfttxt       like datmcntsrv.atddfttxt,
         segnom          like datmcntsrv.segnom,
         aplnumdig       like datmcntsrv.aplnumdig,
         cpfnum          like datmcntsrv.cpfnum,
         ocrufdcod       like datmcntsrv.ocrufdcod,
         ocrcidnom       like datmcntsrv.ocrcidnom,
         ocrbrrnom       like datmcntsrv.ocrbrrnom,
         ocrlgdnom       like datmcntsrv.ocrlgdnom,
         ocrendcmp       like datmcntsrv.ocrendcmp,
         ocrlclcttnom    like datmcntsrv.ocrlclcttnom,
         ocrlcltelnum    like datmcntsrv.ocrlcltelnum,
         ocrlclrefptotxt like datmcntsrv.ocrlclrefptotxt,
         dsttipflg       like datmcntsrv.dsttipflg,
         dstufdcod       like datmcntsrv.dstufdcod,
         dstcidnom       like datmcntsrv.dstcidnom,
         dstbrrnom       like datmcntsrv.dstbrrnom,
         dstlgdnom       like datmcntsrv.dstlgdnom,
         rmcacpflg       like datmcntsrv.rmcacpflg,
         obstxt          like datmcntsrv.obstxt,
         srrcoddig       like datmcntsrv.srrcoddig,
         srrabvnom       like datmcntsrv.srrabvnom,
         atdvclsgl       like datmcntsrv.atdvclsgl,
         atdprscod       like datmcntsrv.atdprscod,
         nomgrr          like datmcntsrv.nomgrr,
         atddat          like datmcntsrv.atddat,
         atdhor          like datmcntsrv.atdhor,
         acndat          like datmcntsrv.acndat,
         acnhor          like datmcntsrv.acnhor,
         acnprv          like datmcntsrv.acnprv,
         c24openom       like datmcntsrv.c24openom,
         c24opemat       like datmcntsrv.c24opemat,
         pasnom1         like datmcntsrv.pasnom1,
         pasida1         like datmcntsrv.pasida1,
         pasnom2         like datmcntsrv.pasnom2,
         pasida2         like datmcntsrv.pasida2,
         pasnom3         like datmcntsrv.pasnom3,
         pasida3         like datmcntsrv.pasida3,
         pasnom4         like datmcntsrv.pasnom4,
         pasida4         like datmcntsrv.pasida4,
         pasnom5         like datmcntsrv.pasnom5,
         pasida5         like datmcntsrv.pasida5,
         atldat          like datmcntsrv.atldat,
         atlhor          like datmcntsrv.atlhor,
         atlmat          like datmcntsrv.atlmat,
         atlnom          like datmcntsrv.atlnom,
         cnlflg          like datmcntsrv.cnlflg,
         cnldat          like datmcntsrv.cnldat,
         cnlhor          like datmcntsrv.cnlhor,
         cnlmat          like datmcntsrv.cnlmat,
         cnlnom          like datmcntsrv.cnlnom,
         socntzcod       like datmcntsrv.socntzcod,
         c24astcod       like datmcntsrv.c24astcod,
         atdorgsrvnum    like datmcntsrv.atdorgsrvnum,
         atdorgsrvano    like datmcntsrv.atdorgsrvano,
         srvtip          like datmcntsrv.srvtip,
         acnifmflg       like datmcntsrv.acnifmflg,
         dstsrvnum       like datmcntsrv.dstsrvnum,
         dstsrvano       like datmcntsrv.dstsrvano,
         prcflg          like datmcntsrv.prcflg,
         ramcod          like datmcntsrv.ramcod,
         succod          like datmcntsrv.succod,
         itmnumdig       like datmcntsrv.itmnumdig,
         ocrlcldddcod    like datmcntsrv.ocrlcldddcod,
         cpfdig          like datmcntsrv.cpfdig,
         cgcord          like datmcntsrv.cgcord,
         ocrendzoncod    like datmcntsrv.ocrendzoncod,
         dstendzoncod    like datmcntsrv.dstendzoncod,
         sindat          like datmcntsrv.sindat,
         sinhor          like datmcntsrv.sinhor,
         bocnum          like datmcntsrv.bocnum,
         boclcldes       like datmcntsrv.boclcldes,
         sinavstip       like datmcntsrv.sinavstip,
         vclchscod       like datmcntsrv.vclchscod,
         obscmptxt       like datmcntsrv.obscmptxt,
         crtsaunum       like datrligsau.crtnum,
         ciaempcod       like datmcntsrv.ciaempcod,
         atdnum          like datmcntsrv.atdnum,
         ocrlcllttnum    like datmcntsrv.ocrlcllttnum,
         ocrlcllgnnum    like datmcntsrv.ocrlcllgnnum,
         ocrlclidxtipcod like datmcntsrv.ocrlclidxtipcod,
         dstlcllttnum    like datmcntsrv.dstlcllttnum,
         dstlcllgnnum    like datmcntsrv.dstlcllgnnum,
         dstlclidxtipcod like datmcntsrv.dstlclidxtipcod,
         vclmoddigcod    like datmcntsrv.vclmoddigcod,
         empcod          like datmcntsrv.empcod,
         h24ctloprempcod like datmcntsrv.h24ctloprempcod,
         usrtipcod       like datmcntsrv.usrtipcod

  end record

  define l_socvclcod      like datkveiculo.socvclcod,
         l_ins_etapa      smallint,
         i                smallint,
         l_inicio         datetime hour to second,
         l_fim            datetime hour to second,
         l_tempo_total    interval hour(03) to second,
         l_camflg         char(1),
         l_aciona         smallint,
         l_funnom         like isskfunc.funnom,
         l_usrtip         like isskfunc.usrtip,
         l_dptnom         like isskdepto.dptnom,
         l_tam_matricula  integer,
         l_matricula      char(10)

  define ws               record
         cont             integer                   ,
         hoje             char(10)                  ,
         anochv           char(02)                  ,
         lignum           like datmligacao.lignum   ,
         atdsrvnum        like datmservico.atdsrvnum,
         atdsrvano        like datmservico.atdsrvano,
         sqlcode          integer                   ,
         msg              char(300),
         tabname          char(300)  ,
         atdetpcod        like datmsrvacp.atdetpcod,
         atdfnlflg        like datmservico.atdfnlflg,
         atdfnlhor        like datmservico.atdfnlhor,
         socvclcod        like datkveiculo.socvclcod,
         asitipcod        like datmservico.asitipcod,
         hist1            char(50),
         hist2            char(50),
         hist3            char(50),
         hist4            char(50),
         hist5            char(50),
         histerr          smallint,
         confirma         char(01),
         atdsrvorg        like datmservico.atdsrvorg,
         msglin1          char(1000),
         msglin2          char(1000),
         msglin3          char(1000),
         msglin4          char(2000),
         msglin5          char(5000),
         msglin6          char(5000),
         vcllibflg        like datmservicocmp.vcllibflg,
         roddantxt        like datmservicocmp. roddantxt,
         bocemi           like datmservicocmp. bocemi,
         sinvitflg        like datmservicocmp.sinvitflg,
         bocflg           like datmservicocmp.bocflg,
         bocnum           like datmservicocmp.bocnum,
         passeq           like datmpassageiro.passeq,
         msglog           char (500),
         acheidocto       char (1),
         tempo            datetime year to second,
         tempo1           datetime year to second,
         atddatprg        like datmservico.atddatprg,
         atdhorprg        like datmservico.atdhorprg,
         sinvstnum        like datmpedvist.sinvstnum,
         promptX          char(01),
         sinntzcod        like datmavssin.sinntzcod,
         resultado        smallint,
         empcod           like datmcntsrv.empcod
 end record

 define l_totreg         smallint,
        l_totpar         smallint,
        l_totsrvifx      smallint,
        l_totsrvctg      smallint,
        l_achei          smallint,
        l_nachei         smallint,
        l_char_funmat    char(06),
        l_char_c24opemat char(10),
        l_char_cnlmat    char(10),
        l_char_vclanomdl char(04),
        l_comando        char(120),
        l_fim_ano        decimal(2,0),
        l_calcula_ano    smallint,
        l_cpocod         decimal(2,0),
        l_primeira_letra char(1) ,
        l_resto_cor      char(19),
        l_msg_final      char(10000),
        l_ambiente       char(08),
        l_assunto        char(100),
        l_tot_geral      smallint,
        l_tot_porto      smallint,
        l_tot_azul       smallint,
        l_tot_itau       smallint, # ITAU (Marcos Goes)
        l_tot_saps       smallint, # SAPS (Celso Issamu)
        l_total          smallint,
        l_status         smallint,
        l_nulo           char(01),
        l_num_char       char(01),
        l_zero           smallint,
        l_processo_ok    smallint,
        l_tot_momento    smallint,
        l_tres           smallint,
        l_ramgrpcod      like gtakram.ramgrpcod,
        l_atualizacao    char(60),
        l_msg_erro       char(40)

 define l_aux            record
        msg_erro         char(40)
 end record
 define lr_aux1 record
        data date,
        hora datetime hour to hour,
        minuto datetime minute to minute,
        altdat char(6),
        data1  char(10)
end record

 define lr_cts05g00 record
        segnom      like gsakseg.segnom,
        corsus      like datmservico.corsus,
        cornom      like datmservico.cornom,
        cvnnom      char(20),
        vclcoddig   like datmservico.vclcoddig,
        vcldes      like datmservico.vcldes,
        vclanomdl   like datmservico.vclanomdl,
        vcllicnum   like datmservico.vcllicnum,
        vclchsinc   like abbmveic.vclchsinc,
        vclchsfnl   like abbmveic.vclchsfnl,
        vclcordes   char (12)
  end record
  define lr_temp record
     flag       smallint                 ,
     cont       integer                  ,
     total      integer                  ,
     c24astcod  like datmcntsrv.c24astcod,
     seqreg     like datmcntsrv.seqreg   ,
     arr        integer                  ,
     passei     smallint
  end record

   define lr_temp_itau record
          vcldes       like datmcntsrv.vcldes,
          vclanomdl    like datmcntsrv.vclanomdl,
          vcllicnum    like datmcntsrv.vcllicnum
   end record

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_totreg          = null
  let l_totpar          = null
  let l_totsrvifx       = null
  let l_totsrvctg       = null
  let l_achei           = null
  let l_nachei          = null
  let l_char_funmat     = null
  let l_char_c24opemat  = null
  let l_char_vclanomdl  = null
  let l_fim_ano         = null
  let l_calcula_ano     = null
  let l_cpocod          = null
  let l_primeira_letra  = null
  let l_resto_cor       = null
  let l_msg_final       = null
  let l_tot_geral       = null
  let l_tot_porto       = null
  let l_tot_azul        = null
  let l_tot_itau        = null
  let l_total           = null
  let l_status          = null
  let l_nulo            = null
  let l_num_char        = null
  let l_comando         = null
  let l_zero            = null
  let l_inicio          = null
  let l_fim             = null
  let l_tempo_total     = null
  let l_assunto         = null
  let l_processo_ok     = null
  let l_ambiente        = null
  let l_tot_momento     = null
  let l_tres            = null
  let m_arq_proc1       = "./rel_erros_processo1.xls"
  let m_arq_proc2       = "./rel_erros_processo2.xls"
  let m_arq_proc3       = "./rel_erros_processo3.xls"
  let m_arq_proc4       = "./rel_erros_processo4.xls"
  let m_cont_proc1      = 0
  let m_cont_proc2      = 0
  let m_cont_proc3      = 0
  let m_cont_proc4      = 0
  let m_status          = null
  let m_msg             = null
  let m_crtsaunum       = null
  let m_bnfnum          = null
  let l_ramgrpcod       = null
  let l_funnom          = null
  let l_usrtip          = null
  let l_dptnom          = null
  let l_tam_matricula   = 0
  let l_matricula       = null
  let l_atualizacao     = null
  let l_msg_erro        = null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  initialize l_datmcntsrv.* to null

  initialize ws.*           to null

  initialize l_aux.*        to null

  initialize lr_cts05g00.*  to null
  initialize lr_temp.*      to null
  initialize lr_aux1.*      to null

  let m_versao = 0
  call cts35m00_verifica_versao()
       returning m_versao
   call cts35m00_prepare()

 # --VERIFICA SE E AMBIENTE DE TESTE OU PRODUCAO - FUNCAO CORPORATIVA(EVANDO PEREIRA)
 if not figrc012_sitename("ofcea060","","") then
    display "ERRO NO ACESSO SITENAME DA DUAL!. AVISE A INFORMATICA !" sleep 5
    return
 end if
 #--------------------------------------------------------
 # Valida Se Processa Automaticamente
 #--------------------------------------------------------
 if cty42g00_automatico() then
 	  #----------------------------------------
 	  # Verifica se Flag Automatico esta Ligado
 	  #----------------------------------------
 	  if not cty42g00_acessa() then
 	  	return
 	  end if
 	  #----------------------------------------
 	  # Verifica se Esta Processando
 	  #----------------------------------------
 	  if cty42g00_processando() then
 	  	return
 	  else
      #----------------------------------------
      # Atualiza Processo para Processando
      #----------------------------------------
 	  	call cty42g00_atualiza("S")
 	  end if
 end if

 if g_outFigrc012.Is_Teste then
    let l_ambiente = "TESTE"
 else
    let l_ambiente = "PRODUCAO"
 end if

 let l_cpocod       = 0
 let l_totreg       = 0
 let l_totpar       = 0
 let l_totsrvifx    = 0
 let l_tot_momento  = 0
 let l_totsrvctg    = 0
 let l_achei        = 0
 let l_nachei       = 0
 let lr_temp.flag   = false
 let lr_temp.passei = false
 let lr_temp.total  = 0
 call cts35m00_verifica_contador()
 returning l_totreg    ,
           l_totsrvifx ,
           l_totsrvctg ,
           l_achei     ,
           l_nachei

 open c_cts35m00_020
 fetch c_cts35m00_020 into l_tot_porto
 close c_cts35m00_020

 open c_cts35m00_027
 fetch c_cts35m00_027 into l_tot_azul
 close c_cts35m00_027

##### BUSCAR TOTAL ITAU #####
# ITAU (Marcos Goes)
 open c_cts35m00_029
 fetch c_cts35m00_029 into l_tot_itau
 close c_cts35m00_029

#### BUSCAR TOTAL SAPS - EMP 43 ####
#CELSO ISSAMU

open c_cts35m00_031
fetch c_cts35m00_031 into l_tot_saps
close c_cts35m00_031


 let l_tot_geral = l_tot_porto + l_tot_azul + l_tot_itau + l_totreg + l_tot_saps

 let ws.msglin1 = "TOTAL REG. P/ CARGA : ", l_tot_geral using "<<<<&"
 let ws.msglin2 = "  Total Reg. Porto  : ", l_tot_porto using "<<<<&"
 let ws.msglin3 = "  Total Reg. Azul   : ", l_tot_azul  using "<<<<&"
 let ws.msglin4 = "  Total Reg. Itau   : ", l_tot_itau  using "<<<<&"
 let ws.msglin5 = "  Total Reg. Saps   : ", l_tot_saps  using "<<<<&"
 ##### ADICIONAR INFORMACAO DE TOTAL ITAU #####


 if not cty42g00_valida() then
    call cts08g01_6l("C","S"
                    ,"CONFIRMA A CARGA DA CONTINGENCIA ?"
                    ,ws.msglin1
                    ,ws.msglin2
                    ,ws.msglin3
                    ,ws.msglin4
                    ,ws.msglin5)
      returning ws.confirma

      if ws.confirma = "N" then
         call cts35m00_deleta_contador()
         return
      end if
      open c_cts35m00_032 using g_issk.empcod,
                                g_issk.funmat
        fetch c_cts35m00_032 into l_funnom,
                                  l_usrtip,
                                  l_dptnom
      close c_cts35m00_032
       let l_matricula = g_issk.funmat
       let l_tam_matricula = length(l_matricula)
	   	if l_tam_matricula <= 5 then
	   	  let l_matricula = l_usrtip
	   	  						,g_issk.empcod using "&&"
	   	              ,g_issk.funmat using "&&&&&"
	   	else
	   	  let l_matricula = l_usrtip
	   	  						,"0"
	   	              ,g_issk.funmat using "&&&&&&"
	   	end if
     let lr_aux1.data = today
     let lr_aux1.hora = current
     let lr_aux1.minuto = current
     let lr_aux1.data1 = lr_aux1.data
     let lr_aux1.altdat = lr_aux1.data1[1,2],
                          lr_aux1.data1[4,5],
                          lr_aux1.data1[9,10]

     let l_atualizacao = lr_aux1.altdat,
                         lr_aux1.hora,
                         lr_aux1.minuto,
                         l_matricula
	   whenever error stop
      execute p_cts35m00_064 using l_atualizacao
      whenever error continue
      let ws.msglin6 = "CARGA ACIONADA POR: " ,"<br>",
                       "Matricula..............: ",l_matricula clipped, "<br>",
                       "Departamento...........: ",l_dptnom    clipped, "<br>",
                       "Nome...................: ",l_funnom    clipped, "<br>"
      let ws.tempo = current year to second

      error "INICIO DA CARGA DA CONTINGENCIA P/ INFORMIX, AGUARDE...", l_tot_geral using "<<<<&"
   end if

   start report cts35m00_rel_proc1 to m_arq_proc1
   start report cts35m00_rel_proc2 to m_arq_proc2
   start report cts35m00_rel_proc3 to m_arq_proc3
   start report cts35m00_rel_proc4 to m_arq_proc4
   # Cria a Temporaria
   if cts35m00_cria_temp() then
      let  lr_temp.flag = true
      call cts35m00_prep_temp()
   end if
   let l_inicio = current

   open c_cts35m00_001
   foreach c_cts35m00_001 into l_datmcntsrv.seqreg
                              ,l_datmcntsrv.seqregcnt
                              ,l_datmcntsrv.atdsrvorg
                              ,l_datmcntsrv.atdsrvnum
                              ,l_datmcntsrv.atdsrvano
                              ,l_datmcntsrv.srvtipabvdes
                              ,l_datmcntsrv.atdnom
                              ,l_datmcntsrv.funmat
                              ,l_datmcntsrv.asitipabvdes
                              ,l_datmcntsrv.c24solnom
                              ,l_datmcntsrv.vcldes
                              ,l_datmcntsrv.vclanomdl
                              ,l_datmcntsrv.vclcor
                              ,l_datmcntsrv.vcllicnum
                              ,l_datmcntsrv.vclcamtip
                              ,l_datmcntsrv.vclcrgflg
                              ,l_datmcntsrv.vclcrgpso
                              ,l_datmcntsrv.atddfttxt
                              ,l_datmcntsrv.segnom
                              ,l_datmcntsrv.aplnumdig
                              ,l_datmcntsrv.cpfnum
                              ,l_datmcntsrv.ocrufdcod
                              ,l_datmcntsrv.ocrcidnom
                              ,l_datmcntsrv.ocrbrrnom
                              ,l_datmcntsrv.ocrlgdnom
                              ,l_datmcntsrv.ocrendcmp
                              ,l_datmcntsrv.ocrlclcttnom
                              ,l_datmcntsrv.ocrlcltelnum
                              ,l_datmcntsrv.ocrlclrefptotxt
                              ,l_datmcntsrv.dsttipflg
                              ,l_datmcntsrv.dstufdcod
                              ,l_datmcntsrv.dstcidnom
                              ,l_datmcntsrv.dstbrrnom
                              ,l_datmcntsrv.dstlgdnom
                              ,l_datmcntsrv.rmcacpflg
                              ,l_datmcntsrv.obstxt
                              ,l_datmcntsrv.srrcoddig
                              ,l_datmcntsrv.srrabvnom
                              ,l_datmcntsrv.atdvclsgl
                              ,l_datmcntsrv.atdprscod
                              ,l_datmcntsrv.nomgrr
                              ,l_datmcntsrv.atddat
                              ,l_datmcntsrv.atdhor
                              ,l_datmcntsrv.acndat
                              ,l_datmcntsrv.acnhor
                              ,l_datmcntsrv.acnprv
                              ,l_datmcntsrv.c24openom
                              ,l_datmcntsrv.c24opemat
                              ,l_datmcntsrv.pasnom1
                              ,l_datmcntsrv.pasida1
                              ,l_datmcntsrv.pasnom2
                              ,l_datmcntsrv.pasida2
                              ,l_datmcntsrv.pasnom3
                              ,l_datmcntsrv.pasida3
                              ,l_datmcntsrv.pasnom4
                              ,l_datmcntsrv.pasida4
                              ,l_datmcntsrv.pasnom5
                              ,l_datmcntsrv.pasida5
                              ,l_datmcntsrv.atldat
                              ,l_datmcntsrv.atlhor
                              ,l_datmcntsrv.atlmat
                              ,l_datmcntsrv.atlnom
                              ,l_datmcntsrv.cnlflg
                              ,l_datmcntsrv.cnldat
                              ,l_datmcntsrv.cnlhor
                              ,l_datmcntsrv.cnlmat
                              ,l_datmcntsrv.cnlnom
                              ,l_datmcntsrv.socntzcod
                              ,l_datmcntsrv.c24astcod
                              ,l_datmcntsrv.atdorgsrvnum
                              ,l_datmcntsrv.atdorgsrvano
                              ,l_datmcntsrv.srvtip
                              ,l_datmcntsrv.acnifmflg
                              ,l_datmcntsrv.dstsrvnum
                              ,l_datmcntsrv.dstsrvano
                              ,l_datmcntsrv.prcflg
                              ,l_datmcntsrv.ramcod
                              ,l_datmcntsrv.succod
                              ,l_datmcntsrv.itmnumdig
                              ,l_datmcntsrv.ocrlcldddcod
                              ,l_datmcntsrv.cpfdig
                              ,l_datmcntsrv.cgcord
                              ,l_datmcntsrv.ocrendzoncod
                              ,l_datmcntsrv.dstendzoncod
                              ,l_datmcntsrv.sindat
                              ,l_datmcntsrv.sinhor
                              ,l_datmcntsrv.bocnum
                              ,l_datmcntsrv.boclcldes
                              ,l_datmcntsrv.sinavstip
                              ,l_datmcntsrv.vclchscod
                              ,l_datmcntsrv.obscmptxt
                              ,l_datmcntsrv.crtsaunum
                              ,l_datmcntsrv.ciaempcod
                              ,l_datmcntsrv.atdnum
                              ,l_datmcntsrv.ocrlcllttnum
                              ,l_datmcntsrv.ocrlcllgnnum
                              ,l_datmcntsrv.ocrlclidxtipcod
                              ,l_datmcntsrv.dstlcllttnum
                              ,l_datmcntsrv.dstlcllgnnum
                              ,l_datmcntsrv.dstlclidxtipcod
                              ,l_datmcntsrv.vclmoddigcod
                              ,l_datmcntsrv.empcod
                              ,l_datmcntsrv.h24ctloprempcod
                              ,l_datmcntsrv.usrtipcod

      #-------------------------------------------------------------------------
      # Carrega as Variaveis com a Matricula de quem Abriu o Servico no 30 horas
      #-------------------------------------------------------------------------
      if l_datmcntsrv.empcod    is not null and
         l_datmcntsrv.usrtipcod is not null and
         l_datmcntsrv.funmat    is not null then
         let g_issk.empcod = l_datmcntsrv.empcod
         let g_issk.usrtip = l_datmcntsrv.usrtipcod
         let g_issk.funmat = l_datmcntsrv.funmat
      end if
      #--------------------------------------------------------
      # Valida Se Ja foi Processado pelo Processo On-line
      #--------------------------------------------------------
      if cty42g00_processado(l_datmcntsrv.seqreg) then
      	 continue foreach
      end if
      # se for null significa que a carga do ASP nao carregou a empresa,
      # neste caso o sistema deve assumir Porto.
      if l_datmcntsrv.ciaempcod is null  or
         l_datmcntsrv.ciaempcod = "  "   then
         let l_datmcntsrv.ciaempcod = 1
      end if
      call cts35m00_grava_sequencia(l_datmcntsrv.seqreg)
          returning lr_temp.seqreg
      if lr_temp.passei = false then
           if lr_temp.seqreg is not null then
               for lr_temp.arr =  lr_temp.seqreg  to l_datmcntsrv.seqreg - 1
                   # Gravo na Temporaria os Registros que Foram Reiniciados
                   if lr_temp.flag then
                       execute p_insert using lr_temp.seqreg
                   end if
                   let lr_temp.seqreg = lr_temp.seqreg + 1
               end for
           end if
           let lr_temp.passei = true
      end if
      # Gravo na Temporaria pelo Fluxo Normal
      if lr_temp.flag then
          execute p_insert using l_datmcntsrv.seqreg
      end if

      begin work

      ----------------[ rotinas comum a Porto, Azul e Itau ]------------------
      let l_totreg = l_totreg + 1
      let l_totpar = l_totpar + 1

     if cty42g00_automatico() then
         display "ATENCAO - REGISTROS LIDOS: ", l_totreg using "<<<<&",
                 " DE: ", l_tot_geral using "<<<<&"
     else
         error "ATENCAO - REGISTROS LIDOS: ", l_totreg using "<<<<&",
               " DE: ", l_tot_geral using "<<<<&"
     end if

      ---[ o ASP carrega branco o laudo entende null, corrigido em 17/05 ]---
      if l_datmcntsrv.ocrendzoncod  =  "  " then
         let l_datmcntsrv.ocrendzoncod = null
      end if
      if l_datmcntsrv.dstendzoncod  =  "  " then
         let l_datmcntsrv.dstendzoncod = null
      end if

      # --VALIDACAO DA MATRICULA-- #
      let l_char_funmat = l_datmcntsrv.funmat
      if length(l_char_funmat) = 6 then  # ex. 101476
         let l_datmcntsrv.funmat = l_char_funmat[2,6]
      end if
      if l_datmcntsrv.c24opemat is not null and
         l_datmcntsrv.c24opemat <> " " then
         let l_char_c24opemat = l_datmcntsrv.c24opemat
         if length(l_char_c24opemat)  = 6 then
            let l_datmcntsrv.c24opemat = l_char_c24opemat[2,6]
         end if
      end if

      if l_datmcntsrv.cnlmat is not null and
         l_datmcntsrv.cnlmat <> " " then
         let l_char_cnlmat = l_datmcntsrv.cnlmat
         if length(l_char_cnlmat)  = 6 then
            let l_datmcntsrv.cnlmat = l_char_cnlmat[2,6]
         end if
      end if


      # Verifica indexacao
      if l_datmcntsrv.ocrlcllttnum = " "   or
         l_datmcntsrv.ocrlcllttnum is null then
         let l_datmcntsrv.ocrlcllttnum = null
      end if

      if l_datmcntsrv.ocrlcllgnnum  = " " or
         l_datmcntsrv.ocrlcllgnnum  is null then
         let l_datmcntsrv.ocrlcllgnnum   = null
      end if

      if l_datmcntsrv.ocrlclidxtipcod is null or
         l_datmcntsrv.ocrlclidxtipcod = " " then
         let l_datmcntsrv.ocrlclidxtipcod = 0
      end if

      if l_datmcntsrv.dstlcllttnum  is null or
         l_datmcntsrv.dstlcllttnum  = " " then
         let l_datmcntsrv.dstlcllttnum = null
      end if

      if l_datmcntsrv.dstlcllgnnum  is null or
         l_datmcntsrv.dstlcllgnnum = " " then
         let l_datmcntsrv.dstlcllttnum = null
      end if

      if l_datmcntsrv.dstlclidxtipcod is null or
         l_datmcntsrv.dstlcllgnnum  = " " then
         let l_datmcntsrv.dstlclidxtipcod = 0
      end if


      open c_cts35m00_003 using l_datmcntsrv.atdvclsgl
      whenever error continue
      fetch c_cts35m00_003 into l_socvclcod
      whenever error stop

      if sqlca.sqlcode <> 0 then
         let l_socvclcod = null
      end if
      close c_cts35m00_003

      # quando o assunto for V12 ou F10 o servico e nulo
      if l_datmcntsrv.atdsrvnum is not null then  # SERVICO CARGA DO IFX

         # --> verifica se o servico existe na datmservico
         open c_cts35m00_019 using l_datmcntsrv.atdsrvnum, l_datmcntsrv.atdsrvano
         whenever error continue
         fetch c_cts35m00_019
         whenever error stop

         if sqlca.sqlcode <> 0 then
            # atualiza prcflg = "S"
            whenever error continue
            execute p_cts35m00_019 using l_datmcntsrv.seqreg
            if sqlca.sqlcode <> 0 then
               display 'erro: ', sqlca.sqlcode, 'servi�o: ',l_datmcntsrv.seqreg
            end if
            whenever error stop

            if sqlca.sqlcode <> 0 then
               output to report cts35m00_rel_proc1(l_datmcntsrv.seqreg,
                                                   l_datmcntsrv.seqregcnt,
                                                   l_datmcntsrv.c24astcod,
                                                   l_datmcntsrv.atdsrvorg,
                                                   l_datmcntsrv.atdsrvnum,
                                                   l_datmcntsrv.atdsrvano,
                                                   l_datmcntsrv.dstsrvnum,
                                                   l_datmcntsrv.dstsrvano,
                                                   l_datmcntsrv.ciaempcod,
                                                   l_datmcntsrv.atldat,
                                                   l_datmcntsrv.atlhor,
                                                   sqlca.sqlcode,
                                                   "Erro de UPDATE na tabela datmcntsrv - 1")
               let m_cont_proc1 = m_cont_proc1 + 1
               rollback  work
               continue foreach
            end if
            let ws.msglin1 = "O SERVICO: ",
                             l_datmcntsrv.atdsrvnum using "<<<<<<<<<&", "-",
                             l_datmcntsrv.atdsrvano using "&&",
                             " NAO EXISTE NA DATMSERVICO."

            output to report cts35m00_rel_proc1(l_datmcntsrv.seqreg,
                                                l_datmcntsrv.seqregcnt,
                                                l_datmcntsrv.c24astcod,
                                                l_datmcntsrv.atdsrvorg,
                                                l_datmcntsrv.atdsrvnum,
                                                l_datmcntsrv.atdsrvano,
                                                l_datmcntsrv.dstsrvnum,
                                                l_datmcntsrv.dstsrvano,
                                                l_datmcntsrv.ciaempcod,
                                                l_datmcntsrv.atldat,
                                                l_datmcntsrv.atlhor,
                                                0,
                                                ws.msglin1)
            let m_cont_proc1 = m_cont_proc1 + 1

            close c_cts35m00_019
            commit work
            continue foreach
         end if

         close c_cts35m00_019

         let l_totsrvifx = l_totsrvifx + 1

         if l_datmcntsrv.atdprscod is not null and
            l_datmcntsrv.atdprscod <> 0   then # acionado

            # Atualizacao da tabela datmservico/etapa
            execute p_cts35m00_004 using l_datmcntsrv.atdprscod
                                        ,l_socvclcod
                                        ,l_datmcntsrv.srrcoddig
                                        ,l_datmcntsrv.srrabvnom
                                        ,l_datmcntsrv.acnhor
                                        ,l_datmcntsrv.c24opemat
                                        ,l_datmcntsrv.acndat
                                        ,l_datmcntsrv.atdsrvnum
                                        ,l_datmcntsrv.atdsrvano
            if sqlca.sqlcode <> 0 then
               output to report cts35m00_rel_proc1(l_datmcntsrv.seqreg,
                                                   l_datmcntsrv.seqregcnt,
                                                   l_datmcntsrv.c24astcod,
                                                   l_datmcntsrv.atdsrvorg,
                                                   l_datmcntsrv.atdsrvnum,
                                                   l_datmcntsrv.atdsrvano,
                                                   l_datmcntsrv.dstsrvnum,
                                                   l_datmcntsrv.dstsrvano,
                                                   l_datmcntsrv.ciaempcod,
                                                   l_datmcntsrv.atldat,
                                                   l_datmcntsrv.atlhor,
                                                   sqlca.sqlcode,
                                                   "Erro de UPDATE na tabela datmservico")
               let m_cont_proc1 = m_cont_proc1 + 1
               rollback work
               continue foreach
            end if

            # --> Gravar etapa do servico
####Alterar tipo de verifica��o#######
            let ws.atdetpcod = 4
            --[para assuntos da Azul a etapa e 4, nao existe etapa de RE]--
            if l_datmcntsrv.ciaempcod = 1 then
               if l_datmcntsrv.c24astcod = "S60" or
                  l_datmcntsrv.c24astcod = "S63" or
                  l_datmcntsrv.c24astcod = "S13" or
                  l_datmcntsrv.c24astcod = "S47" or
                  l_datmcntsrv.c24astcod = "S62" or
                  l_datmcntsrv.c24astcod = "S64" then
                  let ws.atdetpcod = 3
               end if
            end if

            if l_datmcntsrv.ciaempcod = 84 then
               if l_datmcntsrv.c24astcod = "I60" or
                  l_datmcntsrv.c24astcod = "I62" or
                  l_datmcntsrv.c24astcod = "I63" or
                  l_datmcntsrv.c24astcod = "I64" or
                  l_datmcntsrv.c24astcod = "R09" or
                  l_datmcntsrv.c24astcod = "R11" or
                  l_datmcntsrv.c24astcod = "R12" or
                  l_datmcntsrv.c24astcod = "R16" then
                  let ws.atdetpcod = 3
               end if
            end if

           # DEfinir as etapas para os assuntos Saps
           if l_datmcntsrv.ciaempcod = 43 then
              if l_datmcntsrv.c24astcod = "I78" or
                 l_datmcntsrv.c24astcod = "I79" or
                 l_datmcntsrv.c24astcod = "I81" or
                 l_datmcntsrv.c24astcod = "P08" or
                 l_datmcntsrv.c24astcod = "P09" or
                 l_datmcntsrv.c24astcod = "P12" or
                 l_datmcntsrv.c24astcod = "P53" or
                 l_datmcntsrv.c24astcod = "PAS" or
                 l_datmcntsrv.c24astcod = "PBK" then
                 let ws.atdetpcod = 4
              end if
           end if

           if l_datmcntsrv.ciaempcod = 43 then
              if l_datmcntsrv.c24astcod = "I70" or
                 l_datmcntsrv.c24astcod = "I71" or
                 l_datmcntsrv.c24astcod = "I72" or
                 l_datmcntsrv.c24astcod = "I73" or
                 l_datmcntsrv.c24astcod = "I74" or
                 l_datmcntsrv.c24astcod = "I75" or
                 l_datmcntsrv.c24astcod = "I76" or
                 l_datmcntsrv.c24astcod = "I77" or
                 l_datmcntsrv.c24astcod = "I80" or
                 l_datmcntsrv.c24astcod = "I82" or
                 l_datmcntsrv.c24astcod = "I83" or
                 l_datmcntsrv.c24astcod = "P01" or
                 l_datmcntsrv.c24astcod = "P03" or
                 l_datmcntsrv.c24astcod = "P04" or
                 l_datmcntsrv.c24astcod = "P05" or
                 l_datmcntsrv.c24astcod = "P06" or
                 l_datmcntsrv.c24astcod = "P07" or
                 l_datmcntsrv.c24astcod = "P13" or
                 l_datmcntsrv.c24astcod = "P15" or
                 l_datmcntsrv.c24astcod = "P16" or
                 l_datmcntsrv.c24astcod = "P39" or
                 l_datmcntsrv.c24astcod = "P40" or
                 l_datmcntsrv.c24astcod = "P50" or
                 l_datmcntsrv.c24astcod = "PBD" or
                 l_datmcntsrv.c24astcod = "PBE" then
                 let ws.atdetpcod = 3
              end if
           end if



            # -> NAO UTILIZAR ESTA FUNCAO, POIS ELA INSERE DATA E HORA ATUAL
            # -> O CORRETO E INSERIR DATA E HORA DA TABELA datmcntsrv
            ##call cts10g04_insere_etapa(l_datmcntsrv.atdsrvnum
            ##                          ,l_datmcntsrv.atdsrvano
            ##                          ,ws.atdetpcod
            ##                          ,l_datmcntsrv.atdprscod
            ##                          ,l_datmcntsrv.srrabvnom
            ##                          ,l_socvclcod
            ##                          ,l_datmcntsrv.srrcoddig)
            ##   returning l_ins_etapa   #--> Verificar vari�vel

            if ws.atdetpcod = 1 then
               let ws.empcod = l_datmcntsrv.empcod
            else # ACIONAMENTO
               if l_datmcntsrv.h24ctloprempcod is null then
            	    let ws.empcod = 1
         	     else
         	        let ws.empcod = l_datmcntsrv.h24ctloprempcod
         	     end if
            end if

            call cts35m00_insere_etapa(l_datmcntsrv.atdsrvnum,
                                       l_datmcntsrv.atdsrvano,
                                       ws.atdetpcod,
                                       l_datmcntsrv.acndat,
                                       l_datmcntsrv.acnhor,
                                       ws.empcod,
                                       l_datmcntsrv.c24opemat,
                                       l_datmcntsrv.atdprscod,
                                       l_datmcntsrv.srrcoddig,
                                       l_socvclcod,
                                       l_datmcntsrv.srrabvnom)
                 returning l_ins_etapa

            if l_ins_etapa <> 0 then
               output to report cts35m00_rel_proc1(l_datmcntsrv.seqreg,
                                                   l_datmcntsrv.seqregcnt,
                                                   l_datmcntsrv.c24astcod,
                                                   l_datmcntsrv.atdsrvorg,
                                                   l_datmcntsrv.atdsrvnum,
                                                   l_datmcntsrv.atdsrvano,
                                                   l_datmcntsrv.dstsrvnum,
                                                   l_datmcntsrv.dstsrvano,
                                                   l_datmcntsrv.ciaempcod,
                                                   l_datmcntsrv.atldat,
                                                   l_datmcntsrv.atlhor,
                                                   l_ins_etapa,
                                                   "Problema na atualizacao da etapa na tabela datmservico() - 1")
               let m_cont_proc1 = m_cont_proc1 + 1
               rollback work
               continue foreach
            end if

            if l_datmcntsrv.cnlflg = "S" then # serv acionado e canc.

               # -> NAO UTILIZAR ESTA FUNCAO, POIS ELA INSERE DATA E HORA ATUAL
               # -> O CORRETO E INSERIR DATA E HORA DA TABELA datmcntsrv
               ###let l_ins_etapa = cts10g04_insere_etapa
               ###                  (l_datmcntsrv.atdsrvnum
               ###                  ,l_datmcntsrv.atdsrvano
               ###                  ,5
               ###                  ,l_datmcntsrv.atdprscod
               ###                  ,l_datmcntsrv.srrabvnom
               ###                  ,l_socvclcod
               ###                  ,l_datmcntsrv.srrcoddig)

               call cts35m00_insere_etapa(l_datmcntsrv.atdsrvnum,
                                          l_datmcntsrv.atdsrvano,
                                          5,   # ---> ATDETPCOD
                                          l_datmcntsrv.cnldat,
                                          l_datmcntsrv.cnlhor,
                                          1, # EMPCOD
                                          l_datmcntsrv.cnlmat,
                                          l_datmcntsrv.atdprscod,
                                          l_datmcntsrv.srrcoddig,
                                          l_socvclcod,
                                          l_datmcntsrv.srrabvnom)
                    returning l_ins_etapa

               if l_ins_etapa <> 0 then
                  output to report cts35m00_rel_proc1
                         (l_datmcntsrv.seqreg,
                          l_datmcntsrv.seqregcnt,
                          l_datmcntsrv.c24astcod,
                          l_datmcntsrv.atdsrvorg,
                          l_datmcntsrv.atdsrvnum,
                          l_datmcntsrv.atdsrvano,
                          l_datmcntsrv.dstsrvnum,
                          l_datmcntsrv.dstsrvano,
                          l_datmcntsrv.ciaempcod,
                          l_datmcntsrv.atldat,
                          l_datmcntsrv.atlhor,
                          l_ins_etapa,
                          "Erro ao chamar a funcao cts35m00_insere_etapa() - 2")
                  let m_cont_proc1 = m_cont_proc1 + 1
                  rollback work
                  continue foreach
               end if
            end if
         else   # SERVICO NAO ACIONADO
            if l_datmcntsrv.cnlflg = "S"  then   # SERVICO CANCELADO
               # servico do ifx nao acionado na contingencia
               # flag "S" para nao aparecer no radio.
               whenever error continue
               execute p_cts35m00_018 using l_datmcntsrv.atdsrvnum,
                                            l_datmcntsrv.atdsrvano
               whenever error stop
               if sqlca.sqlcode <> 0 then
                  output to report cts35m00_rel_proc1(l_datmcntsrv.seqreg,
                                                      l_datmcntsrv.seqregcnt,
                                                      l_datmcntsrv.c24astcod,
                                                      l_datmcntsrv.atdsrvorg,
                                                      l_datmcntsrv.atdsrvnum,
                                                      l_datmcntsrv.atdsrvano,
                                                      l_datmcntsrv.dstsrvnum,
                                                      l_datmcntsrv.dstsrvano,
                                                      l_datmcntsrv.ciaempcod,
                                                      l_datmcntsrv.atldat,
                                                      l_datmcntsrv.atlhor,
                                                      sqlca.sqlcode,
                                                      "Erro de UPDATE na tabela datmservico - 1")
                  let m_cont_proc1 = m_cont_proc1 + 1
                  rollback work
                  continue foreach
               end if

               # -> NAO UTILIZAR ESTA FUNCAO, POIS ELA INSERE DATA E HORA ATUAL
               # -> O CORRETO E INSERIR DATA E HORA DA TABELA datmcntsrv
               ##let l_ins_etapa = cts10g04_insere_etapa
               ##                  (l_datmcntsrv.atdsrvnum
               ##                  ,l_datmcntsrv.atdsrvano
               ##                  ,5
               ##                  ,l_datmcntsrv.atdprscod
               ##                  ,l_datmcntsrv.srrabvnom
               ##                  ,l_socvclcod
               ##                  ,l_datmcntsrv.srrcoddig)

               call cts35m00_insere_etapa(l_datmcntsrv.atdsrvnum,
                                          l_datmcntsrv.atdsrvano,
                                          5,     # ---> ATDETPCOD
                                          l_datmcntsrv.cnldat,
                                          l_datmcntsrv.cnlhor,
                                          1, # EMPCOD
                                          l_datmcntsrv.cnlmat,
                                          l_datmcntsrv.atdprscod,
                                          l_datmcntsrv.srrcoddig,
                                          l_socvclcod,
                                          l_datmcntsrv.srrabvnom)
                    returning l_ins_etapa

               if l_ins_etapa <> 0 then
                  output to report cts35m00_rel_proc1(l_datmcntsrv.seqreg,
                                                      l_datmcntsrv.seqregcnt,
                                                      l_datmcntsrv.c24astcod,
                                                      l_datmcntsrv.atdsrvorg,
                                                      l_datmcntsrv.atdsrvnum,
                                                      l_datmcntsrv.atdsrvano,
                                                      l_datmcntsrv.dstsrvnum,
                                                      l_datmcntsrv.dstsrvano,
                                                      l_datmcntsrv.ciaempcod,
                                                      l_datmcntsrv.atldat,
                                                      l_datmcntsrv.atlhor,
                                                      l_ins_etapa,
                                                      "Erro ao chamar a funcao cts35m00_insere_etapa() - 3")
                  let m_cont_proc1 = m_cont_proc1 + 1
                  rollback work
                  continue foreach
               end if
            end if
         end if

         whenever error continue
         execute p_cts35m00_019 using l_datmcntsrv.seqreg
         if sqlca.sqlcode <> 0 then
            display 'erro: ', sqlca.sqlcode, 'servi�o: ',l_datmcntsrv.seqreg
         end if
         whenever error stop

         if sqlca.sqlcode <> 0 then
            output to report cts35m00_rel_proc1(l_datmcntsrv.seqreg,
                                                l_datmcntsrv.seqregcnt,
                                                l_datmcntsrv.c24astcod,
                                                l_datmcntsrv.atdsrvorg,
                                                l_datmcntsrv.atdsrvnum,
                                                l_datmcntsrv.atdsrvano,
                                                l_datmcntsrv.dstsrvnum,
                                                l_datmcntsrv.dstsrvano,
                                                l_datmcntsrv.ciaempcod,
                                                l_datmcntsrv.atldat,
                                                l_datmcntsrv.atlhor,
                                                sqlca.sqlcode,
                                                "Erro de UPDATE na tabela datmcntsrv - 2")
            let m_cont_proc1 = m_cont_proc1 + 1
            rollback work
         end if
      end if

      # ITAU (Marcos Goes)
      --------- [ fim das rotinas comum a Porto, Azul e Itau ]---------------- ##### ITAU TAMBEM #####
      if l_datmcntsrv.atdsrvnum is null  then
         #servi�o gerado pela contingencia
         let l_totsrvctg = l_totsrvctg + 1

         ##### CRIAR ROTINA DE PESQUISA PARA DADOS ITAU #####
         # ITAU (Marcos Goes)
         if l_datmcntsrv.ciaempcod = 84 then   # carga ctg Itau

            initialize lr_temp_itau.* to null

            let lr_temp_itau.vcldes    = l_datmcntsrv.vcldes
            let lr_temp_itau.vclanomdl = l_datmcntsrv.vclanomdl
            let lr_temp_itau.vcllicnum = l_datmcntsrv.vcllicnum

            initialize g_documento,
                       l_aux.msg_erro to null
             if l_datmcntsrv.ramcod = 14 or
                l_datmcntsrv.ramcod = 114 then     ### JUNIOR FORNAX
                call cts35m07_PesquisaApoliceItau(l_datmcntsrv.seqreg)
                     returning ws.msg
                              ,ws.resultado
                              ,lr_cts05g00.segnom
                              ,lr_cts05g00.corsus
                              ,lr_cts05g00.cornom
                              ,lr_cts05g00.cvnnom

                    if ws.resultado = 1 then
                       let ws.acheidocto = "S"
                       call errorlog("Achei o documento")
                       let g_documento.edsnumref = 0
                    else
                      call errorlog("N�o o documento")
                      let ws.acheidocto = "N"
                    end if

             else
                call cts35m06_PesquisaApoliceItau(l_datmcntsrv.seqreg)
                returning ws.msg
                         ,ws.resultado
                         ,lr_cts05g00.segnom
                         ,lr_cts05g00.corsus
                         ,lr_cts05g00.cornom
                         ,lr_cts05g00.cvnnom
                         ,lr_cts05g00.vclcoddig
                         ,lr_cts05g00.vclchsinc
                         ,lr_cts05g00.vclchsfnl
                         ,l_datmcntsrv.vcldes
                         ,l_datmcntsrv.vclanomdl
                         ,l_datmcntsrv.vcllicnum
                if ws.resultado = 1 then
                   let ws.acheidocto = "S"
                   let g_documento.edsnumref = 0
                else
                   let ws.acheidocto = "N"
                end if

                if l_datmcntsrv.vcldes = " " or
                   l_datmcntsrv.vcldes is null then
                   let l_datmcntsrv.vcldes = lr_temp_itau.vcldes
                end if

                if l_datmcntsrv.vclanomdl = " " or
                   l_datmcntsrv.vclanomdl is null then
                   let l_datmcntsrv.vclanomdl = lr_temp_itau.vclanomdl
                end if

                if l_datmcntsrv.vcllicnum = " " or
                   l_datmcntsrv.vcllicnum is null then
                   let l_datmcntsrv.vcllicnum = lr_temp_itau.vcllicnum
                end if

               end if
         end if

         if l_datmcntsrv.ciaempcod = 35 then   # carga ctg Azul Seguros
            --------[pesquisa por apolice, placa e cgccpf ]---------
            initialize g_documento,
                       l_aux.msg_erro to null
            call cts35m04_PesquisaApoliceAzul(l_datmcntsrv.seqreg,
                                              l_datmcntsrv.funmat,
                                              l_datmcntsrv.c24opemat)
                 returning ws.msg,
                           ws.resultado,
                           lr_cts05g00.segnom,
                           lr_cts05g00.corsus,
                           lr_cts05g00.cornom,
                           lr_cts05g00.cvnnom,
                           lr_cts05g00.vclcoddig,
                           lr_cts05g00.vclchsinc,
                           lr_cts05g00.vclchsfnl,
                           l_datmcntsrv.vcldes,
                           l_datmcntsrv.vclanomdl,
                           l_datmcntsrv.vcllicnum
            if ws.resultado = 1 then
               let ws.acheidocto = "S"
               let g_documento.edsnumref = 0
            else
               let ws.acheidocto = "N"
            end if
         end if

         #N�o h� pesquisa de ap�lice para SAPS

         if l_datmcntsrv.ciaempcod = 1 then  # Porto Seguro
            ------[ PESQUISA APOLICE PARA PORTO ]----------
            initialize g_documento, l_aux.msg_erro to null

            let ws.acheidocto         = "N"
            let g_documento.edsnumref = 0

            --[ apolice ]--
            if l_datmcntsrv.ramcod is not null    and
               l_datmcntsrv.ramcod <> 0           then

               ### PSI 202720 - Obter o cartao saude
               call cty10g00_grupo_ramo(1, l_datmcntsrv.ramcod)
                    returning m_status
                             ,m_msg
                             ,l_ramgrpcod

               if l_ramgrpcod = 5 then ## Saude
                 call cta01m15_sel_datksegsau(6,l_datmcntsrv.crtsaunum,"","","")
                       returning m_status, m_msg, m_crtsaunum, m_bnfnum
                  if m_status = 1 then
                     let ws.acheidocto = "S"
                     let g_documento.crtsaunum = m_crtsaunum
                     let g_documento.bnfnum    = m_bnfnum
                     ----[ busca numero do cartao p/ gravar datrsrvsau ]----
                     open c_cts35m00_026 using g_documento.crtsaunum
                     whenever error continue
                     fetch c_cts35m00_026 into m_succod,
                                             m_ramcod,
                                             m_aplnumdig
                     whenever error stop
                     close c_cts35m00_026
                  end if
               else
                  if l_datmcntsrv.succod is not null    and
                     l_datmcntsrv.succod <> 0           and
                     l_datmcntsrv.aplnumdig is not null and
                     l_datmcntsrv.aplnumdig <> 0        and
                     l_datmcntsrv.itmnumdig is not null then
                     # em apolice do RE o item e zero
                     let l_aux.msg_erro = cts35m00_apolice(l_datmcntsrv.ramcod
                                                          ,l_datmcntsrv.succod
                                                          ,l_datmcntsrv.aplnumdig
                                                          ,l_datmcntsrv.itmnumdig)
                     if l_aux.msg_erro is null then
                        let ws.acheidocto = "S"
                     end if
                  end if
               end if
            end if
            if ws.acheidocto = "N" then
               initialize l_aux.msg_erro to null
               --[ placa ]
               if l_datmcntsrv.vcllicnum is not null  and
                  l_datmcntsrv.vcllicnum <> "       " and  # 7p. campo tabela
                  l_ramgrpcod            <> 5         then # grupo 5 = Saude
                  let l_aux.msg_erro = cts35m00_placa(l_datmcntsrv.vcllicnum)
                  if l_aux.msg_erro is null then
                     let ws.acheidocto = "S"
                  end if
               end if

               if ws.acheidocto = "N" then
                  initialize l_aux.msg_erro to null
                  --[cpf ]
                  if l_datmcntsrv.cpfnum is not null and
                     l_datmcntsrv.cpfnum <> 0        then
                     call cts35m00_cgccpf(l_datmcntsrv.cpfnum
                                         ,l_datmcntsrv.cgcord
                                         ,l_datmcntsrv.cpfdig
                                         ,l_datmcntsrv.ramcod
                                         ,l_ramgrpcod ) ## PSI 272720
                       returning l_aux.msg_erro
                     if l_aux.msg_erro is null then
                        let ws.acheidocto = "S"
                     end if
                  end if
                  if ws.acheidocto = "N" then
                     -----[ pesquisa cartao saude por nome ]-------
                     if l_ramgrpcod = 5 and
                        l_datmcntsrv.segnom is not null then
                        call cts35m00_nome(l_datmcntsrv.segnom)
                             returning l_aux.msg_erro
                        if l_aux.msg_erro is null then
                           let ws.acheidocto = "S"
                        end if
                     end if
                  end if
               end if
            end if
         end if    # if ciaempcod = 1

         if l_aux.msg_erro is null and
            ws.acheidocto  = "S"   then
            let l_achei = l_achei + 1
         else
            let l_nachei = l_nachei + 1
         end if

         if g_documento.aplnumdig is not null  and
            g_documento.aplnumdig <> 0        then

            if g_documento.succod    is null or
               g_documento.itmnumdig is null then

               let ws.msglog = "** CTS35m00-item ou suc nulo, reg= ",
                               l_datmcntsrv.seqreg
               output to report cts35m00_rel_proc1(l_datmcntsrv.seqreg,
                                                   l_datmcntsrv.seqregcnt,
                                                   l_datmcntsrv.c24astcod,
                                                   l_datmcntsrv.atdsrvorg,
                                                   ws.atdsrvnum,
                                                   ws.atdsrvano,
                                                   l_datmcntsrv.dstsrvnum,
                                                   l_datmcntsrv.dstsrvano,
                                                   l_datmcntsrv.ciaempcod,
                                                   l_datmcntsrv.atldat,
                                                   l_datmcntsrv.atlhor,
                                                   0,
                                                   ws.msglog)
               let m_cont_proc1 = m_cont_proc1 + 1
              #rollback work
              #continue foreach

               initialize g_documento to null

            end if
         end if
         if l_datmcntsrv.c24astcod = "V12" then
            commit work
            call cts35m01(l_datmcntsrv.seqreg,
                          l_datmcntsrv.funmat,
                          l_datmcntsrv.c24opemat,
                          g_documento.succod,
                          g_documento.ramcod,
                          g_documento.aplnumdig,
                          g_documento.itmnumdig)
                 returning ws.msg,
                           ws.sqlcode,
                           ws.sinvstnum
            if ws.sqlcode <> 0 then
               let ws.msg  = ws.msg clipped, " ",
                               "problemas na funcao cts35m01"
               output to report cts35m00_rel_proc1
                              (l_datmcntsrv.seqreg,
                               l_datmcntsrv.seqregcnt,
                               l_datmcntsrv.c24astcod,
                               "", #l_datmcntsrv.atdsrvorg,
                               ws.sinvstnum,
                               "", #ws.atdsrvano,
                               l_datmcntsrv.dstsrvnum,
                               l_datmcntsrv.dstsrvano,
                               l_datmcntsrv.ciaempcod,
                               l_datmcntsrv.atldat,
                               l_datmcntsrv.atlhor,
                               ws.sqlcode,
                               ws.msg   )
            end if
            continue foreach
         end if

         let ws.atdsrvorg = 1

         ##### ADICIONAR BLOCO PARA ASSUNTOS ITAU #####

         if l_datmcntsrv.c24astcod = "S60" or
            l_datmcntsrv.c24astcod = "S63" or
            l_datmcntsrv.c24astcod = "S13" or
            l_datmcntsrv.c24astcod = "S47" or
            l_datmcntsrv.c24astcod = "S62" or
            l_datmcntsrv.c24astcod = "S64" or
            l_datmcntsrv.c24astcod = "I70" or     # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "I71" or     # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "I72" or     # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "I73" or     # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "I74" or     # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "I75" or     # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "I76" or     # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "I77" or     # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "I83" or     # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "P01" or     # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "P03" or     # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "P04" or     # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "P05" or     # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "P06" or     # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "P07" or     # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "P13" or     # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "P15" or     # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "P39" or     # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "P40" or     # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "P50" or     # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "PBD" or     # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "PBE" or     # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "P16" or     # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "I80" or     # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "I82" or     # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "I60" or     # ITAU (Marcos Goes)
            l_datmcntsrv.c24astcod = "I62" or     # ITAU (Marcos Goes)
            l_datmcntsrv.c24astcod = "I63" or     # ITAU (Marcos Goes)
            l_datmcntsrv.c24astcod = "I64" or     # ITAU (Marcos Goes)
            l_datmcntsrv.c24astcod = "R09" or     # ITAU (JUNIOR FORNAX)
            l_datmcntsrv.c24astcod = "R11" or     # ITAU (JUNIOR FORNAX)
            l_datmcntsrv.c24astcod = "R12" or     # ITAU (JUNIOR FORNAX)
            l_datmcntsrv.c24astcod = "R16" or     # ITAU (JUNIOR FORNAX)
            l_datmcntsrv.c24astcod = "RAI" then   # ITAU (JUNIOR FORNAX)
            let ws.atdsrvorg = 9
         end if

         if l_datmcntsrv.c24astcod = "S23" or
            l_datmcntsrv.c24astcod = "S53" or
            l_datmcntsrv.c24astcod = "T23" or
            l_datmcntsrv.c24astcod = "K23" or
            l_datmcntsrv.c24astcod = "K53" or
            l_datmcntsrv.c24astcod = "K93" or
            l_datmcntsrv.c24astcod = "I23" or     # ITAU (Marcos Goes)
            l_datmcntsrv.c24astcod = "I24" or     # ITAU (Marcos Goes)
            l_datmcntsrv.c24astcod = "R06" or     # ITAU (Marcos Goes)
            l_datmcntsrv.c24astcod = "I25" or     # ITAU (Marcos Goes)
            l_datmcntsrv.c24astcod = "P53" then   # SAPS (Celso Yamahaki)
            let ws.atdsrvorg = 2
         end if

         if l_datmcntsrv.c24astcod = "S33"  or
            l_datmcntsrv.c24astcod = "K14"  or
            l_datmcntsrv.c24astcod = "K33"  or
            l_datmcntsrv.c24astcod = "K43"  or
            l_datmcntsrv.c24astcod = "T33"  or
            l_datmcntsrv.c24astcod = "I33"  or     # ITAU (Marcos Goes)
            l_datmcntsrv.c24astcod = "I34"  or     # ITAU (Marcos Goes)
            l_datmcntsrv.c24astcod = "I35"  or     # ITAU (Marcos Goes)
            l_datmcntsrv.c24astcod = "K93"  then
            let ws.atdsrvorg = 3
         end if
         if l_datmcntsrv.c24astcod = "D13" or
            l_datmcntsrv.c24astcod = "P09" or   # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "P12"      # SAPS (Celso Yamahaki)
            then
            let ws.atdsrvorg = 6
         end if
         if l_datmcntsrv.c24astcod[1] = "G" or
            l_datmcntsrv.c24astcod = "F13" or
            l_datmcntsrv.c24astcod = "I10" or
            l_datmcntsrv.c24astcod = "L10" or
            l_datmcntsrv.c24astcod = "E10" or
            l_datmcntsrv.c24astcod = "E12" or
            l_datmcntsrv.c24astcod = "T12" or
            l_datmcntsrv.c24astcod = "T13" or
            l_datmcntsrv.c24astcod = "K17" or  #Amilton
            l_datmcntsrv.c24astcod = "K18" or  #Amilton
            l_datmcntsrv.c24astcod = "K19" or  #Amilton
            l_datmcntsrv.c24astcod = "K21" or  #Amilton
            l_datmcntsrv.c24astcod = "K37" or
            l_datmcntsrv.c24astcod = "K15" or
            l_datmcntsrv.c24astcod = "I79" or  # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "I81" or  # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "I03" or     # ITAU (Marcos Goes)
            l_datmcntsrv.c24astcod = "I04" or     # ITAU (Marcos Goes)
            l_datmcntsrv.c24astcod = "I05" or     # ITAU (Marcos Goes)
            l_datmcntsrv.c24astcod = "I06" or     # ITAU (Marcos Goes)
            l_datmcntsrv.c24astcod = "I17" or     # ITAU (Marcos Goes)
            l_datmcntsrv.c24astcod = "I19" or     # ITAU (Marcos Goes)
            l_datmcntsrv.c24astcod = "IOF" or     # ITAU (Marcos Goes)
            #l_datmcntsrv.c24astcod = "IPT" or     # ITAU (Marcos Goes)
            l_datmcntsrv.c24astcod = "I19" then   # ITAU (Marcos Goes)
            let ws.atdsrvorg = 4
            if l_datmcntsrv.c24astcod = "IPT" then 
               let ws.atdsrvorg = 5
            end if 	
         end if
         if l_datmcntsrv.c24astcod = "I07" or     # ITAU (Marcos Goes)
            l_datmcntsrv.c24astcod = "I08" or     # ITAU (Marcos Goes)
            l_datmcntsrv.c24astcod = "I20" then   # ITAU (Marcos Goes)
            let ws.atdsrvorg = 8
         end if
         if l_datmcntsrv.c24astcod    = "F10" then
            let ws.atdsrvorg = 11
         end if
         if ws.atdsrvorg <> 9 then
            # --VALIDACAO DO CODIGO DA COR DO VEICULO-- #
            # --NA TELA DA CONTINGENCIA(ASP) A COR DO VEICULO E MAISCULA-- #
            let l_primeira_letra = l_datmcntsrv.vclcor[1]
            let l_resto_cor      = l_datmcntsrv.vclcor[2,20]
            let l_resto_cor      = downshift(l_resto_cor)
            # MONTAGEM DA COR:PRIMEIRA LETRA MAIUSCULA RESTANTES MINUSCULAS #
            let l_datmcntsrv.vclcor = l_primeira_letra, l_resto_cor


            if l_datmcntsrv.vclmoddigcod is null then
               let lr_cts05g00.vclcoddig = 99999
            else
               let lr_cts05g00.vclcoddig = l_datmcntsrv.vclmoddigcod
            end if

            # -> VERIFICA SE TEMOS APOLICE
            if g_documento.aplnumdig is not null and
               g_documento.aplnumdig <> 0        then

               # -> BUSCA OS DADOS DO VEICULO DA APOLICE
               if l_datmcntsrv.ciaempcod = 1 then # Porto
                  call cts05g00(g_documento.succod,
                                g_documento.ramcod,
                                g_documento.aplnumdig,
                                g_documento.itmnumdig)

                       returning lr_cts05g00.segnom,
                                 lr_cts05g00.corsus,
                                 lr_cts05g00.cornom,
                                 lr_cts05g00.cvnnom,
                                 lr_cts05g00.vclcoddig,
                                 l_datmcntsrv.vcldes,
                                 l_datmcntsrv.vclanomdl,
                                 l_datmcntsrv.vcllicnum,
                                 lr_cts05g00.vclchsinc,
                                 lr_cts05g00.vclchsfnl,
                                 l_datmcntsrv.vclcor
               end if
            else
               # --VALIDACAO DO ANO DO VEICULO-- #
               let l_char_vclanomdl = l_datmcntsrv.vclanomdl
               let l_fim_ano        = l_char_vclanomdl[3,4]
               if l_fim_ano > 50 then
                  let l_calcula_ano = (1900 + l_fim_ano)
               end if
               if l_fim_ano <= 50 then
                  let l_calcula_ano = (2000 + l_fim_ano)
               end if
               let l_char_vclanomdl       = l_calcula_ano
               let l_datmcntsrv.vclanomdl = l_char_vclanomdl
            end if

            open c_cts35m00_010 using l_datmcntsrv.vclcor
            whenever error continue
            fetch c_cts35m00_010 into l_cpocod
            whenever error stop

            if sqlca.sqlcode = notfound then
               let l_cpocod = 0
            end if

            close c_cts35m00_010

         end if
         --[ gerar aviso qdo nao localizar apolice - Silmara 22/01/07 ]--
         if l_datmcntsrv.c24astcod = "F10"    then
            commit work
            call cts35m03(l_datmcntsrv.seqreg,
                          l_datmcntsrv.funmat,
                          l_datmcntsrv.c24opemat,
                          g_documento.succod,
                          g_documento.ramcod,
                          g_documento.aplnumdig,
                          g_documento.itmnumdig,
                          ws.atdsrvorg         ,
                          l_datmcntsrv.vclanomdl,
                          l_cpocod)
                 returning ws.msg,
                           ws.sqlcode,
                           ws.atdsrvnum,
                           ws.atdsrvano
            if ws.sqlcode <> 0 then
               let ws.msg  = ws.msg clipped, " ",
                               "problemas na funcao cts35m03"
               output to report cts35m00_rel_proc1
                              (l_datmcntsrv.seqreg,
                               l_datmcntsrv.seqregcnt,
                               l_datmcntsrv.c24astcod,
                               5                     ,
                               ws.atdsrvnum,
                               ws.atdsrvano,
                               l_datmcntsrv.dstsrvnum,
                               l_datmcntsrv.dstsrvano,
                               l_datmcntsrv.ciaempcod,
                               l_datmcntsrv.atldat,
                               l_datmcntsrv.atlhor,
                               ws.sqlcode,
                               ws.msg   )
            end if
            execute p_cts35m00_028 using ws.atdsrvnum,
                                       ws.atdsrvano,
                                       l_datmcntsrv.seqreg
            # Gravo o Furto e Roubo para posteriormente gerar o processamento via MQ
            call cts35m05_grava_furto(ws.atdsrvano,ws.atdsrvnum)
            continue foreach
         end if

         let ws.asitipcod = 1

         if l_datmcntsrv.asitipabvdes = "Chaveiro" then
            let ws.asitipcod = 4
         end if
         if l_datmcntsrv.asitipabvdes = "Tecnico"  then
            let ws.asitipcod = 2
         end if
         if l_datmcntsrv.asitipabvdes = "Guincho"  then
            let ws.asitipcod = 1
         end if
         if l_datmcntsrv.asitipabvdes = "Gui/Tecnico" then
            let ws.asitipcod = 3
         end if
         if l_datmcntsrv.asitipabvdes = "Taxi"     then
            let ws.asitipcod = 5
         end if
         if l_datmcntsrv.asitipabvdes = "Hospedag" then
            let ws.asitipcod = 5
         end if
         if l_datmcntsrv.asitipabvdes = "Passagem" then
            let ws.asitipcod = 10
         end if
         if l_datmcntsrv.asitipabvdes = "R.E." or
            l_datmcntsrv.asitipabvdes = "RE" then
            let ws.asitipcod = 6
         end if

         let ws.atdetpcod = 1
         let ws.atdfnlflg = "N"
         let ws.atdfnlhor = null
         # Se servico estiver cancelado finalizo o atendimento
         if l_datmcntsrv.cnlflg = "S" then
             let ws.atdfnlflg = "S"
         end if

         if l_datmcntsrv.atdprscod is not null and
            l_datmcntsrv.atdprscod <> 0        then #-->Servi�o Acionado
               let ws.atdfnlflg = "S"
               let ws.atdfnlhor = l_datmcntsrv.acnhor
               let ws.atdetpcod = 4
               if l_datmcntsrv.c24astcod = "S60" or
                  l_datmcntsrv.c24astcod = "S63" or
                  l_datmcntsrv.c24astcod = "S13" or
                  l_datmcntsrv.c24astcod = "S47" or
                  l_datmcntsrv.c24astcod = "S62" or
                  l_datmcntsrv.c24astcod = "S64" or
                  l_datmcntsrv.c24astcod = "I70" or     # SAPS (Celso Yamahaki)
                  l_datmcntsrv.c24astcod = "I71" or     # SAPS (Celso Yamahaki)
                  l_datmcntsrv.c24astcod = "I72" or     # SAPS (Celso Yamahaki)
                  l_datmcntsrv.c24astcod = "I73" or     # SAPS (Celso Yamahaki)
                  l_datmcntsrv.c24astcod = "I74" or     # SAPS (Celso Yamahaki)
                  l_datmcntsrv.c24astcod = "I75" or     # SAPS (Celso Yamahaki)
                  l_datmcntsrv.c24astcod = "I76" or     # SAPS (Celso Yamahaki)
                  l_datmcntsrv.c24astcod = "I77" or     # SAPS (Celso Yamahaki)
                  l_datmcntsrv.c24astcod = "I83" or     # SAPS (Celso Yamahaki)
                  l_datmcntsrv.c24astcod = "P01" or     # SAPS (Celso Yamahaki)
                  l_datmcntsrv.c24astcod = "P03" or     # SAPS (Celso Yamahaki)
                  l_datmcntsrv.c24astcod = "P04" or     # SAPS (Celso Yamahaki)
                  l_datmcntsrv.c24astcod = "P05" or     # SAPS (Celso Yamahaki)
                  l_datmcntsrv.c24astcod = "P06" or     # SAPS (Celso Yamahaki)
                  l_datmcntsrv.c24astcod = "P07" or     # SAPS (Celso Yamahaki)
                  l_datmcntsrv.c24astcod = "P13" or     # SAPS (Celso Yamahaki)
                  l_datmcntsrv.c24astcod = "P15" or     # SAPS (Celso Yamahaki)
                  l_datmcntsrv.c24astcod = "P39" or     # SAPS (Celso Yamahaki)
                  l_datmcntsrv.c24astcod = "P40" or     # SAPS (Celso Yamahaki)
                  l_datmcntsrv.c24astcod = "P50" or     # SAPS (Celso Yamahaki)
                  l_datmcntsrv.c24astcod = "PBD" or     # SAPS (Celso Yamahaki)
                  l_datmcntsrv.c24astcod = "PBE" or     # SAPS (Celso Yamahaki)
                  l_datmcntsrv.c24astcod = "P16" or     # SAPS (Celso Yamahaki)
                  l_datmcntsrv.c24astcod = "I80" or     # SAPS (Celso Yamahaki)
                  l_datmcntsrv.c24astcod = "I82" or     # SAPS (Celso Yamahaki)
                  l_datmcntsrv.c24astcod = "I60" or     # ITAU (Marcos Goes)
                  l_datmcntsrv.c24astcod = "I62" or     # ITAU (Marcos Goes)
                  l_datmcntsrv.c24astcod = "I63" or     # ITAU (Marcos Goes)
                  l_datmcntsrv.c24astcod = "I64" or     # ITAU (Marcos Goes)
                  l_datmcntsrv.c24astcod = "R09" or     # ITAU (JUNIOR FORNAX)
                  l_datmcntsrv.c24astcod = "R11" or     # ITAU (JUNIOR FORNAX)
                  l_datmcntsrv.c24astcod = "R12" or     # ITAU (JUNIOR FORNAX)
                  l_datmcntsrv.c24astcod = "R16" or     # ITAU (JUNIOR FORNAX)
                  l_datmcntsrv.c24astcod = "RAI" then   # ITAU (JUNIOR FORNAX)
                     let ws.atdetpcod = 3
               end if
         end if
         call cts10g03_numeracao(2,3)
               returning ws.lignum
                        ,ws.atdsrvnum
                        ,ws.atdsrvano
                        ,ws.sqlcode
                        ,ws.msg
         if ws.sqlcode <> 0 then
            let ws.msg = ws.msg clipped, " ",
                         "chamada da funcao cts10g03_numeracao()"
            output to report cts35m00_rel_proc1(l_datmcntsrv.seqreg,
                                                l_datmcntsrv.seqregcnt,
                                                l_datmcntsrv.c24astcod,
                                                l_datmcntsrv.atdsrvorg,
                                                ws.atdsrvnum,
                                                ws.atdsrvano,
                                                l_datmcntsrv.dstsrvnum,
                                                l_datmcntsrv.dstsrvano,
                                                l_datmcntsrv.ciaempcod,
                                                l_datmcntsrv.atldat,
                                                l_datmcntsrv.atlhor,
                                                ws.sqlcode,
                                                ws.msg)
            let m_cont_proc1 = m_cont_proc1 + 1
            rollback work
            continue foreach
         else
            commit work
            begin work
         end if
         if (g_documento.aplnumdig is not null and
             g_documento.aplnumdig <> 0) or
            (g_documento.crtsaunum is not null and
             g_documento.crtsaunum <> 0)       then
            whenever error continue
            if g_documento.aplnumdig is not null and
               g_documento.aplnumdig <> 0 then
               # atualiza datrservapol
               execute p_cts35m00_021 using ws.atdsrvnum,
                                            ws.atdsrvano,
                                            g_documento.succod,
                                            g_documento.ramcod,
                                            g_documento.aplnumdig,
                                            g_documento.itmnumdig,
                                            g_documento.edsnumref
               whenever error stop
               if sqlca.sqlcode <> 0  then
                  output to report cts35m00_rel_proc1(l_datmcntsrv.seqreg,
                                                      l_datmcntsrv.seqregcnt,
                                                      l_datmcntsrv.c24astcod,
                                                      l_datmcntsrv.atdsrvorg,
                                                      ws.atdsrvnum,
                                                      ws.atdsrvano,
                                                      l_datmcntsrv.dstsrvnum,
                                                      l_datmcntsrv.dstsrvano,
                                                      l_datmcntsrv.ciaempcod,
                                                      l_datmcntsrv.atldat,
                                                      l_datmcntsrv.atlhor,
                                                      sqlca.sqlcode,
                                                      "Erro de INSERT na tabela datrservapol")
                  let m_cont_proc1 = m_cont_proc1 + 1
                  rollback work
                  continue foreach
               end if
            else
             if g_documento.crtsaunum is not null and
                g_documento.crtsaunum <> 0        then
               # atualiza datrsrvsau
               execute p_cts35m00_047 using ws.atdsrvnum,
                                            ws.atdsrvano,
                                            m_succod,
                                            m_ramcod,
                                            m_aplnumdig,
                                            g_documento.crtsaunum,
                                            g_documento.bnfnum
               whenever error stop
               if sqlca.sqlcode <> 0  then
                  output to report cts35m00_rel_proc1(l_datmcntsrv.seqreg,
                                                      l_datmcntsrv.seqregcnt,
                                                      l_datmcntsrv.c24astcod,
                                                      l_datmcntsrv.atdsrvorg,
                                                      ws.atdsrvnum,
                                                      ws.atdsrvano,
                                                      l_datmcntsrv.dstsrvnum,
                                                      l_datmcntsrv.dstsrvano,
                                                      l_datmcntsrv.ciaempcod,
                                                      l_datmcntsrv.atldat,
                                                      l_datmcntsrv.atlhor,
                                                      sqlca.sqlcode,
                                                      "Erro de INSERT na tabela datrsrvsau")
                  let m_cont_proc1 = m_cont_proc1 + 1
                  rollback work
                  continue foreach
               end if
             end if
            end if
         end if

         if l_datmcntsrv.atldat is null or
         	  l_datmcntsrv.atldat = ""    then
              let l_datmcntsrv.atldat = l_datmcntsrv.atddat
         end if
         if l_datmcntsrv.atlhor is null or
         	  l_datmcntsrv.atlhor = ""    then
              let l_datmcntsrv.atlhor = l_datmcntsrv.atdhor
         end if
         call cts10g00_ligacao
               ( ws.lignum             ,#
                 l_datmcntsrv.atldat   ,#
                 l_datmcntsrv.atlhor   ,#
                 1                     ,#c24soltipcod
                 l_datmcntsrv.c24solnom,#
                 l_datmcntsrv.c24astcod,#
                 l_datmcntsrv.funmat   ,#
                 0                     ,#ligcvntip
                 0                     ,#c24paxnum
                 ws.atdsrvnum          ,#
                 ws.atdsrvano          ,#
                 ""                    ,#sinvstnum
                 ""                    ,#sinvstano
                 ""                    ,#sinavsnum
                 ""                    ,#sinavsano
                 g_documento.succod    ,#
                 g_documento.ramcod    ,#
                 g_documento.aplnumdig ,#
                 g_documento.itmnumdig ,#
                 g_documento.edsnumref ,#
                 g_documento.prporg    ,#
                 g_documento.prpnumdig ,#
                 g_documento.fcapacorg ,#
                 g_documento.fcapacnum ,#
                 ""                    ,#sinramcod
                 ""                    ,#sinano
                 ""                    ,#sinnum
                 ""                    ,#sinitmseq
                 today                 ,#caddat
                 current hour to minute,#cadhor
                 1                     ,#cademp
                 l_datmcntsrv.funmat   )#cadmat
             returning ws.tabname,
                       ws.sqlcode

         if ws.sqlcode  <>  0  then
            let ws.tabname = ws.tabname clipped, " --> TABELA , chamada da funcao cts10g00_ligacao()"
            output to report cts35m00_rel_proc1(l_datmcntsrv.seqreg,
                                                l_datmcntsrv.seqregcnt,
                                                l_datmcntsrv.c24astcod,
                                                l_datmcntsrv.atdsrvorg,
                                                ws.atdsrvnum,
                                                ws.atdsrvano,
                                                l_datmcntsrv.dstsrvnum,
                                                l_datmcntsrv.dstsrvano,
                                                l_datmcntsrv.ciaempcod,
                                                l_datmcntsrv.atldat,
                                                l_datmcntsrv.atlhor,
                                                ws.sqlcode,
                                                ws.tabname)
            let m_cont_proc1 = m_cont_proc1 + 1
            rollback work
            continue foreach
         end if
         if l_datmcntsrv.atdnum <> 0 and
            l_datmcntsrv.atdnum is not null then
             ---------[ grava na tabela de Atendimento Decreto 6523 ]-------------
             call ctd24g00_ins_atd(l_datmcntsrv.atdnum      ,
                                   l_datmcntsrv.ciaempcod   ,
                                   l_datmcntsrv.c24solnom   ,
                                   ""                       ,
                                   1                        ,
                                   g_documento.ramcod       ,
                                   ""                       ,
                                   l_datmcntsrv.vcllicnum   ,
                                   lr_cts05g00.corsus       ,
                                   g_documento.succod       ,
                                   g_documento.aplnumdig    ,
                                   g_documento.itmnumdig    ,
                                   ""                       ,
                                   l_datmcntsrv.segnom      ,
                                   ""                       ,
                                   l_datmcntsrv.cpfnum      ,
                                   l_datmcntsrv.cgcord      ,
                                   l_datmcntsrv.cpfdig      ,
                                   g_documento.prporg       ,
                                   g_documento.prpnumdig    ,
                                   ""                       ,
                                   ""                       ,
                                   ""                       ,
                                   ""                       ,
                                   ""                       ,
                                   ""                       ,
                                   ""                       ,
                                   ""                       ,
                                   ""                       ,
                                   ""                       ,
                                   ""                       ,
                                   lr_cts05g00.vclchsfnl    ,
                                   ""                       ,
                                   ""                       ,
                                   ""                       ,
                                   ""                       ,
                                   ""                       ,
                                   ""                       ,
                                   ""                       ,
                                   ""                       ,
                                   ""                       ,
                                   ""                       ,
                                   ""                       ,
                                   ""                       ,
                                   ""                       ,
                                   ""                       ,
                                   ""                       ,
                                   ""                       ,
                                   ""                       ,
                                   ""                       ,
                                   ""                       ,
                                   ""                       ,
                                   ""                       ,
                                   ""                       ,
                                   ""                       ,
                                   ""                       ,
                                   l_datmcntsrv.funmat      ,
                                   l_datmcntsrv.ciaempcod   ,
                                   ""                       ,
                                   0 )
              returning l_datmcntsrv.atdnum,
                        ws.sqlcode         ,
                        ws.tabname
              if ws.sqlcode  <>  0   and
                 ws.sqlcode  <>  4   then
                 let ws.tabname = ws.tabname clipped, " datmatd6523 --> TABELA , chamada da funcao ctd24g00_ins_atd()"
                 output to report cts35m00_rel_proc1(l_datmcntsrv.seqreg,
                                                     l_datmcntsrv.seqregcnt,
                                                     l_datmcntsrv.c24astcod,
                                                     l_datmcntsrv.atdsrvorg,
                                                     ws.atdsrvnum,
                                                     ws.atdsrvano,
                                                     l_datmcntsrv.dstsrvnum,
                                                     l_datmcntsrv.dstsrvano,
                                                     l_datmcntsrv.ciaempcod,
                                                     l_datmcntsrv.atldat,
                                                     l_datmcntsrv.atlhor,
                                                     ws.sqlcode,
                                                     ws.tabname)
                 let m_cont_proc1 = m_cont_proc1 + 1
                 rollback work
                 continue foreach
              end if
             ---------[ grava relacionamento Atendimento X Ligacao ]-------------
             call ctd25g00_insere_atendimento(l_datmcntsrv.atdnum ,ws.lignum)
             returning ws.sqlcode,ws.msg
             if ws.sqlcode  <>  0  then
                #let ws.msg = " datratdlig --> TABELA , chamada da funcao ctd25g00_insere_atendimento()"
                let ws.msg = ws.msg clipped, " ",
                         "chamada da funcao ctd25g00_insere_atendimento()"
                output to report cts35m00_rel_proc1(l_datmcntsrv.seqreg,
                                                    l_datmcntsrv.seqregcnt,
                                                    l_datmcntsrv.c24astcod,
                                                    l_datmcntsrv.atdsrvorg,
                                                    ws.atdsrvnum,
                                                    ws.atdsrvano,
                                                    l_datmcntsrv.dstsrvnum,
                                                    l_datmcntsrv.dstsrvano,
                                                    l_datmcntsrv.ciaempcod,
                                                    l_datmcntsrv.atldat,
                                                    l_datmcntsrv.atlhor,
                                                    ws.sqlcode,
                                                    ws.msg)
                let m_cont_proc1 = m_cont_proc1 + 1
                rollback work
                continue foreach
             end if
          end if
         ---------[ verifica se o servico e programado ]-------------
         let ws.atddatprg = null
         let ws.atdhorprg = null
         if (l_datmcntsrv.atddat > today) or
            (l_datmcntsrv.atddat = today  and
             l_datmcntsrv.atdhor > current hour to minute) then
             let ws.atddatprg = l_datmcntsrv.atddat
             let ws.atdhorprg = l_datmcntsrv.atdhor
         end if

         #Inicializa a global com empresa 43
         if l_datmcntsrv.ciaempcod = 43 then
         call cts35m00_cgccpf_portofaz(ws.lignum,
                                          l_datmcntsrv.cpfnum,
                                          l_datmcntsrv.cgcord,
                                          l_datmcntsrv.cpfdig)
            returning l_msg_erro
            let g_documento.ciaempcod = 43
            let g_documento.c24astcod = l_datmcntsrv.c24astcod
         end if


         call cts10g02_grava_servico
              ( ws.atdsrvnum,
                ws.atdsrvano,
                1 ,
                l_datmcntsrv.c24solnom,
                l_cpocod,
                l_datmcntsrv.funmat ,
                "S",
                l_datmcntsrv.atlhor ,
                l_datmcntsrv.atldat,
                l_datmcntsrv.atldat,
                l_datmcntsrv.atlhor,
                "",
                "00:00",
                ws.atddatprg,
                ws.atdhorprg,
                3 ,
                "",
                "",
                l_datmcntsrv.atdprscod,
                "",
                ws.atdfnlflg,
                ws.atdfnlhor,
                "N",
                l_datmcntsrv.atddfttxt,  # d_cts03m00.atddfttxt,
                ""                    ,  # atddoctxt
                l_datmcntsrv.c24opemat , # w_cts03m00.c24opemat,
                l_datmcntsrv.segnom    , # d_cts03m00.nom      ,
                l_datmcntsrv.vcldes    , # d_cts03m00.vcldes   ,
                l_datmcntsrv.vclanomdl , # d_cts03m00.vclanomdl,
                l_datmcntsrv.vcllicnum , # d_cts03m00.vcllicnum,
                lr_cts05g00.corsus     , # d_cts03m00.corsus   ,
                lr_cts05g00.cornom     , # d_cts03m00.cornom   ,
                l_datmcntsrv.acndat    , # w_cts03m00.cnldat   ,
                ""                     , # pgtdat
                l_datmcntsrv.srrabvnom , # w_cts03m00.c24nomctt,
                "N"                    , # w_cts03m00.atdpvtretflg,
                ""                     , # w_cts03m00.atdvcltip,
                ws.asitipcod           , # d_cts03m00.asitipcod ,
                l_socvclcod            , # socvclcod
                lr_cts05g00.vclcoddig  , # d_cts03m00.vclcoddig,
                "N"                    , # d_cts03m00.srvprlflg,
                l_datmcntsrv.srrcoddig,  # srrcoddig
                1                      , # d_cts03m00.atdprinvlcod,
                ws.atdsrvorg )           # d_cts03m00.atdsrvorg)
         returning ws.tabname,
                   ws.sqlcode

         if ws.sqlcode <> 0 then
            let ws.tabname = ws.tabname clipped, " --> TABELA , chamada da funcao cts10g02_grava_servico()"
            output to report cts35m00_rel_proc1(l_datmcntsrv.seqreg,
                                                l_datmcntsrv.seqregcnt,
                                                l_datmcntsrv.c24astcod,
                                                l_datmcntsrv.atdsrvorg,
                                                ws.atdsrvnum,
                                                ws.atdsrvano,
                                                l_datmcntsrv.dstsrvnum,
                                                l_datmcntsrv.dstsrvano,
                                                l_datmcntsrv.ciaempcod,
                                                l_datmcntsrv.atldat,
                                                l_datmcntsrv.atlhor,
                                                ws.sqlcode,
                                                ws.tabname)
            let m_cont_proc1 = m_cont_proc1 + 1
            rollback work
            continue foreach
         end if
         if l_datmcntsrv.atddfttxt is not null and
            l_datmcntsrv.atddfttxt <> " "      then
            ---------[ Grava descricao do problema(datrsrvpbm) ]---------
            call ctx09g02_inclui(ws.atdsrvnum,
                                 ws.atdsrvano,
                                 1      , # Org. informacao 1-Segurado 2-Pst
                                 999                 ,
                                 l_datmcntsrv.atddfttxt,
                                 ""                  ) # Codigo prestador
                 returning ws.sqlcode, ws.tabname

            if ws.sqlcode <> 0 then
               let ws.tabname = ws.tabname clipped, " --> TABELA , chamada da funcao ctx09g02_inclui()"
               output to report cts35m00_rel_proc1(l_datmcntsrv.seqreg,
                                                   l_datmcntsrv.seqregcnt,
                                                   l_datmcntsrv.c24astcod,
                                                   l_datmcntsrv.atdsrvorg,
                                                   ws.atdsrvnum,
                                                   ws.atdsrvano,
                                                   l_datmcntsrv.dstsrvnum,
                                                   l_datmcntsrv.dstsrvano,
                                                   l_datmcntsrv.ciaempcod,
                                                   l_datmcntsrv.atldat,
                                                   l_datmcntsrv.atlhor,
                                                   ws.sqlcode,
                                                   ws.tabname)
               let m_cont_proc1 = m_cont_proc1 + 1
               rollback work
               continue foreach
           end if
         end if


         ##### INSERIR BLOCO(S) PARA SERVICO ITAU #####
         #####  SERVICOS QUE TENHAM COMPLEMENTO   #####

         # - Inserir complemento do servico
         if l_datmcntsrv.c24astcod <> "S60" and
            l_datmcntsrv.c24astcod <> "S63" and
            l_datmcntsrv.c24astcod <> "S13" and
            l_datmcntsrv.c24astcod <> "S47" and
            l_datmcntsrv.c24astcod <> "S62" and
            l_datmcntsrv.c24astcod <> "S64" and
            l_datmcntsrv.c24astcod <> "S23" and
            l_datmcntsrv.c24astcod <> "S53" and
            l_datmcntsrv.c24astcod <> "S33" and
            l_datmcntsrv.c24astcod <> "T23" and
            l_datmcntsrv.c24astcod <> "T33" and
            ---------[ assuntos SAPS ]---------
            l_datmcntsrv.c24astcod <> 'I70' and
            l_datmcntsrv.c24astcod <> 'I71' and
            l_datmcntsrv.c24astcod <> 'I72' and
            l_datmcntsrv.c24astcod <> 'I73' and
            l_datmcntsrv.c24astcod <> 'I74' and
            l_datmcntsrv.c24astcod <> 'I75' and
            l_datmcntsrv.c24astcod <> 'I76' and
            l_datmcntsrv.c24astcod <> 'I77' and
            l_datmcntsrv.c24astcod <> 'I80' and
            l_datmcntsrv.c24astcod <> 'I82' and
            l_datmcntsrv.c24astcod <> 'I83' and
            l_datmcntsrv.c24astcod <> 'P01' and
            l_datmcntsrv.c24astcod <> 'P03' and
            l_datmcntsrv.c24astcod <> 'P04' and
            l_datmcntsrv.c24astcod <> 'P05' and
            l_datmcntsrv.c24astcod <> 'P06' and
            l_datmcntsrv.c24astcod <> 'P07' and
            l_datmcntsrv.c24astcod <> 'P13' and
            l_datmcntsrv.c24astcod <> 'P15' and
            l_datmcntsrv.c24astcod <> 'P16' and
            l_datmcntsrv.c24astcod <> 'P39' and
            l_datmcntsrv.c24astcod <> 'P40' and
            l_datmcntsrv.c24astcod <> 'P50' and
            l_datmcntsrv.c24astcod <> 'PBD' and
            l_datmcntsrv.c24astcod <> 'PBE' and
            l_datmcntsrv.c24astcod <> 'P53' and

            ---[ assuntos da Azul Seguros ]----
            l_datmcntsrv.c24astcod <> "K23" and
            l_datmcntsrv.c24astcod <> "K33" and
            l_datmcntsrv.c24astcod <> "K93" and
            l_datmcntsrv.c24astcod <> "K14" and
            l_datmcntsrv.c24astcod <> "K33" and
            l_datmcntsrv.c24astcod <> "K43" and
            ---[ assuntos da ITAU Seguros ]----
            l_datmcntsrv.c24astcod <> "I60" and   # ITAU (Marcos Goes)
            l_datmcntsrv.c24astcod <> "I62" and   # ITAU (Marcos Goes)
            l_datmcntsrv.c24astcod <> "I63" and   # ITAU (Marcos Goes)
            l_datmcntsrv.c24astcod <> "I13" and   # ITAU (Marcos Goes)
            l_datmcntsrv.c24astcod <> "R06" and   # ITAU (JUNIOR FORNAX)
            l_datmcntsrv.c24astcod <> "R09" and   # ITAU (JUNIOR FORNAX)
            l_datmcntsrv.c24astcod <> "R11" and   # ITAU (JUNIOR FORNAX)
            l_datmcntsrv.c24astcod <> "R12" and   # ITAU (JUNIOR FORNAX)
            l_datmcntsrv.c24astcod <> "R16" and   # ITAU (JUNIOR FORNAX)
            l_datmcntsrv.c24astcod <> "RAI" then  # ITAU (JUNIOR FORNAX)

            let ws.sinvitflg = "N"
            let ws.bocflg    = "N"
            let ws.bocnum    = ""
            let ws.bocemi    = ""
            let ws.vcllibflg = ""
            let ws.roddantxt = ""

            whenever error continue
            execute p_cts35m00_022 using ws.atdsrvnum,
                                       ws.atdsrvano,
                                       l_datmcntsrv.rmcacpflg,
                                       l_datmcntsrv.vclcamtip,
                                       l_datmcntsrv.vclcrgflg,
                                       l_datmcntsrv.vclcrgpso
            whenever error stop

            if sqlca.sqlcode <> 0 then
               output to report cts35m00_rel_proc1(l_datmcntsrv.seqreg,
                                                   l_datmcntsrv.seqregcnt,
                                                   l_datmcntsrv.c24astcod,
                                                   l_datmcntsrv.atdsrvorg,
                                                   ws.atdsrvnum,
                                                   ws.atdsrvano,
                                                   l_datmcntsrv.dstsrvnum,
                                                   l_datmcntsrv.dstsrvano,
                                                   l_datmcntsrv.ciaempcod,
                                                   l_datmcntsrv.atldat,
                                                   l_datmcntsrv.atlhor,
                                                   sqlca.sqlcode,
                                "Erro de INSERT na tabela datmservicocmp")
               let m_cont_proc1 = m_cont_proc1 + 1
               rollback work
               continue foreach
            end if
         end if

         if l_datmcntsrv.c24astcod = "S60" or
            l_datmcntsrv.c24astcod = "S63" or
            l_datmcntsrv.c24astcod = "S13" or
            l_datmcntsrv.c24astcod = "S47" or
            l_datmcntsrv.c24astcod = "S62" or
            l_datmcntsrv.c24astcod = "S64" or
            l_datmcntsrv.c24astcod = "I70" or    # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "I71" or    # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "I72" or    # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "I73" or    # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "I74" or    # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "I75" or    # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "I76" or    # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "I77" or    # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "I80" or    # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "I82" or    # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "I83" or    # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "P01" or    # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "P03" or    # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "P04" or    # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "P05" or    # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "P06" or    # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "P07" or    # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "P13" or    # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "P15" or    # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "P16" or    # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "P39" or    # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "P40" or    # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "P50" or    # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "PBD" or    # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "PBE" or    # SAPS (Celso Yamahaki)
            l_datmcntsrv.c24astcod = "I60" or    # ITAU (Marcos Goes)
            l_datmcntsrv.c24astcod = "I62" or    # ITAU (Marcos Goes)
            l_datmcntsrv.c24astcod = "I63" or    # ITAU (Marcos Goes)
            l_datmcntsrv.c24astcod = "I13" or    # ITAU (Marcos Goes)
            l_datmcntsrv.c24astcod = "R09" or    # ITAU (JUNIOR FORNAX)
            l_datmcntsrv.c24astcod = "R11" or    # ITAU (JUNIOR FORNAX)
            l_datmcntsrv.c24astcod = "R12" or    # ITAU (JUNIOR FORNAX)
            l_datmcntsrv.c24astcod = "R16" or    # ITAU (JUNIOR FORNAX)
            l_datmcntsrv.c24astcod = "RAI" then  # ITAU (JUNIOR FORNAX)

            # Gravar tabela RE

            whenever error continue
            execute p_cts35m00_023 using ws.atdsrvnum,
                                       ws.atdsrvano,
                                       l_datmcntsrv.socntzcod,
                                       l_datmcntsrv.atdorgsrvnum,
                                       l_datmcntsrv.atdorgsrvano
            whenever error stop

            if sqlca.sqlcode <> 0 then
               output to report cts35m00_rel_proc1(l_datmcntsrv.seqreg,
                                                   l_datmcntsrv.seqregcnt,
                                                   l_datmcntsrv.c24astcod,
                                                   l_datmcntsrv.atdsrvorg,
                                                   ws.atdsrvnum,
                                                   ws.atdsrvano,
                                                   l_datmcntsrv.dstsrvnum,
                                                   l_datmcntsrv.dstsrvano,
                                                   l_datmcntsrv.ciaempcod,
                                                   l_datmcntsrv.atldat,
                                                   l_datmcntsrv.atlhor,
                                                   sqlca.sqlcode,
                                        "Erro de INSERT na tabela datmsrvre")
               let m_cont_proc1 = m_cont_proc1 + 1
               rollback work
               continue foreach
            end if

         end if

         #VER ASSUNTOS SAPS QUE NECESSITAM DE COMPLEMENTO.

         if l_datmcntsrv.c24astcod = "S23" or
            l_datmcntsrv.c24astcod = "S33" or
            l_datmcntsrv.c24astcod = "S53" or
            l_datmcntsrv.c24astcod = "T23" or
            l_datmcntsrv.c24astcod = "T33" or

            l_datmcntsrv.c24astcod = "P53" or  # SAPS (Celso Yamahaki)

            ---[ assuntos da Azul Seguros ]---
            l_datmcntsrv.c24astcod = "K14" or
            l_datmcntsrv.c24astcod = "K23" or
            l_datmcntsrv.c24astcod = "K33" or
            l_datmcntsrv.c24astcod = "K43" or
            l_datmcntsrv.c24astcod = "K53" or
            l_datmcntsrv.c24astcod = "K93" or
            l_datmcntsrv.c24astcod = "I23" or    # ITAU (Marcos Goes)
            l_datmcntsrv.c24astcod = "I33" or    # ITAU (Marcos Goes)
            l_datmcntsrv.c24astcod = "I24" or    # ITAU (Marcos Goes)
            l_datmcntsrv.c24astcod = "R06" then  # ITAU (JUNIOR FORNAX)

            if l_datmcntsrv.pasnom1 is not null or
               l_datmcntsrv.pasnom2 is not null or
               l_datmcntsrv.pasnom3 is not null or
               l_datmcntsrv.pasnom4 is not null or
               l_datmcntsrv.pasnom5 is not null then
              #GRAVAR TABELA DE PASSAGEIROS
               whenever error continue
               execute p_cts35m00_024 using ws.atdsrvnum,
                                            ws.atdsrvano
               whenever error stop

               if sqlca.sqlcode <> 0 then
                  output to report cts35m00_rel_proc1(l_datmcntsrv.seqreg,
                                                      l_datmcntsrv.seqregcnt,
                                                      l_datmcntsrv.c24astcod,
                                                      l_datmcntsrv.atdsrvorg,
                                                      ws.atdsrvnum,
                                                      ws.atdsrvano,
                                                      l_datmcntsrv.dstsrvnum,
                                                      l_datmcntsrv.dstsrvano,
                                                      l_datmcntsrv.ciaempcod,
                                                      l_datmcntsrv.atldat,
                                                      l_datmcntsrv.atlhor,
                                                      sqlca.sqlcode,
                                   "Erro de INSERT na tabela datmassistpassag")
                  let m_cont_proc1 = m_cont_proc1 + 1
                  rollback work
                  continue foreach
               end if

                 #GRAVAR TABELA DATMPASSAGEIRO
                 #montar esta rotina para 5 ocorrencia

                 initialize ws.passeq to null

                 for i = 1 to 5
                   if i = 1 then
                      let l_datmcntsrv.pasnom1 = l_datmcntsrv.pasnom1
                      let l_datmcntsrv.pasida1 = l_datmcntsrv.pasida1
                   else
                      if i = 2 then
                         let l_datmcntsrv.pasnom1 = l_datmcntsrv.pasnom2
                         let l_datmcntsrv.pasida1 = l_datmcntsrv.pasida2
                      else
                         if i = 3 then
                            let l_datmcntsrv.pasnom1 = l_datmcntsrv.pasnom3
                            let l_datmcntsrv.pasida1 = l_datmcntsrv.pasida3
                         else
                            if i = 4 then
                               let l_datmcntsrv.pasnom1=l_datmcntsrv.pasnom4
                               let l_datmcntsrv.pasida1=l_datmcntsrv.pasida4
                            else
                              if i = 5 then
                                let l_datmcntsrv.pasnom1=l_datmcntsrv.pasnom5
                                let l_datmcntsrv.pasida1=l_datmcntsrv.pasida5
                              end if
                            end if
                         end if
                      end if
                   end if

                   if l_datmcntsrv.pasnom1 is null or l_datmcntsrv.pasnom1 = ' ' then
                      continue for
                   end if

                   if l_datmcntsrv.pasida1 is null then
                      let l_datmcntsrv.pasida1 = 0
                   end if

                   open c_cts35m00_011 using ws.atdsrvnum,
                                           ws.atdsrvano
                   whenever error continue
                   fetch c_cts35m00_011 into ws.passeq
                   whenever error stop
                   close c_cts35m00_011

                   if ws.passeq is null  then
                      let ws.passeq = 0
                   end if

                   let ws.passeq = ws.passeq + 1

                   whenever error continue
                   execute p_cts35m00_026 using ws.atdsrvnum,
                                              ws.atdsrvano,
                                              ws.passeq,
                                              l_datmcntsrv.pasnom1,
                                              l_datmcntsrv.pasida1
                   whenever error stop
                   if sqlca.sqlcode  <>  0 then
                      output to report cts35m00_rel_proc1(l_datmcntsrv.seqreg,
                                                      l_datmcntsrv.seqregcnt,
                                                      l_datmcntsrv.c24astcod,
                                                      l_datmcntsrv.atdsrvorg,
                                                      ws.atdsrvnum,
                                                      ws.atdsrvano,
                                                      l_datmcntsrv.dstsrvnum,
                                                      l_datmcntsrv.dstsrvano,
                                                      l_datmcntsrv.ciaempcod,
                                                      l_datmcntsrv.atldat,
                                                      l_datmcntsrv.atlhor,
                                                      sqlca.sqlcode,
                                     "Erro de INSERT na tabela datmpassageiro")
                      let m_cont_proc1 = m_cont_proc1 + 1
                      rollback work
                      continue foreach
                   end if
                 end for
            end if
         end if
         if l_datmcntsrv.ocrlgdnom is not null and
            l_datmcntsrv.ocrlgdnom <> " "      then # endereco ocorrencia
            let l_nulo     = null
            let l_num_char = "1"
            let l_zero     = 0
            let l_tres     = 3
            whenever error continue
            execute p_cts35m00_027 using ws.atdsrvnum,                     #atdsrvnum,
                                         ws.atdsrvano,                     #atdsrvano,
                                         l_num_char,                       #c24endtip,
                                         l_nulo,                           #lclidttxt,
                                         l_nulo,                           #lgdtip,
                                         l_datmcntsrv.ocrlgdnom,           #lgdnom,
                                         l_zero,                           #lgdnum,
                                         l_datmcntsrv.ocrbrrnom,           #lclbrrnom,
                                         l_datmcntsrv.ocrbrrnom,           #brrnom,
                                         l_datmcntsrv.ocrcidnom,           #cidnom,
                                         l_datmcntsrv.ocrufdcod,           #ufdcod,
                                         l_datmcntsrv.ocrlclrefptotxt,     #lclrefptotxt,
                                         l_datmcntsrv.ocrendzoncod,        #endzon,
                                         l_nulo,                           #lgdcep,
                                         l_nulo,                           #lgdcepcmp,
                                         l_datmcntsrv.ocrlcllttnum,        #lclltt,
                                         l_datmcntsrv.ocrlcllgnnum,        #lcllgt,
                                         l_datmcntsrv.ocrlcldddcod,        #dddcod,
                                         l_datmcntsrv.ocrlcltelnum,        #lcltelnum,
                                         l_datmcntsrv.ocrlclcttnom,        #lclcttnom,
                                         l_datmcntsrv.ocrlclidxtipcod,     #l_tres, Raji 26/01/2007 #c24lclpdrcod,
                                         l_nulo,                           #ofnnumdig,
                                         l_datmcntsrv.ocrendcmp            #endcmp
            whenever error stop
            if sqlca.sqlcode <> 0 then
               output to report cts35m00_rel_proc1(l_datmcntsrv.seqreg,
                                                   l_datmcntsrv.seqregcnt,
                                                   l_datmcntsrv.c24astcod,
                                                   l_datmcntsrv.atdsrvorg,
                                                   ws.atdsrvnum,
                                                   ws.atdsrvano,
                                                   l_datmcntsrv.dstsrvnum,
                                                   l_datmcntsrv.dstsrvano,
                                                   l_datmcntsrv.ciaempcod,
                                                   l_datmcntsrv.atldat,
                                                   l_datmcntsrv.atlhor,
                                                   sqlca.sqlcode,
                                       "Erro de INSERT na tabela datmlcl - 1")
               let m_cont_proc1 = m_cont_proc1 + 1
               rollback work
               continue foreach
            end if
         end if
         if l_datmcntsrv.dstlgdnom is not null and
            l_datmcntsrv.dstlgdnom <>  " "     then # endereco destino
            let l_nulo     = null
            let l_num_char = "2"
            let l_zero     = 0
            let l_tres     = 3
            whenever error continue
            execute p_cts35m00_027 using ws.atdsrvnum,                    #atdsrvnum,
                                       ws.atdsrvano,                      #atdsrvano,
                                       l_num_char,                        #c24endtip,
                                       l_nulo,                            #lclidttxt,
                                       l_nulo,                            #lgdtip,
                                       l_datmcntsrv.dstlgdnom,            #lgdnom,
                                       l_zero,                            #lgdnum,
                                       l_datmcntsrv.dstbrrnom,            #lclbrrnom,
                                       l_datmcntsrv.dstbrrnom,            #brrnom,
                                       l_datmcntsrv.dstcidnom,            #cidnom,
                                       l_datmcntsrv.dstufdcod,            #ufdcod,
                                       l_nulo,                            #lclrefptotxt,
                                       l_datmcntsrv.dstendzoncod,         #endzon,
                                       l_nulo,                            #lgdcep,  ,
                                       l_nulo,                            #lgdcepcmp,
                                       l_datmcntsrv.dstlcllttnum,         #lclltt,  ,
                                       l_datmcntsrv.dstlcllgnnum,         #lcllgt,
                                       l_nulo,                            #dddcod,
                                       l_nulo,                            #lcltelnum,
                                       l_nulo,                            #lclcttnom,
                                       l_datmcntsrv.dstlclidxtipcod,      #l_tres, Raji 26/01/2007  #c24lclpdrcod,
                                       l_nulo,                            #ofnnumdig,
                                       l_nulo                             #endcmp
            whenever error stop
            if sqlca.sqlcode <> 0 then
               output to report cts35m00_rel_proc1(l_datmcntsrv.seqreg,
                                                   l_datmcntsrv.seqregcnt,
                                                   l_datmcntsrv.c24astcod,
                                                   l_datmcntsrv.atdsrvorg,
                                                   ws.atdsrvnum,
                                                   ws.atdsrvano,
                                                   l_datmcntsrv.dstsrvnum,
                                                   l_datmcntsrv.dstsrvano,
                                                   l_datmcntsrv.ciaempcod,
                                                   l_datmcntsrv.atldat,
                                                   l_datmcntsrv.atlhor,
                                                   sqlca.sqlcode,
                                   "Erro de INSERT na tabela datmlcl - 2")
               let m_cont_proc1 = m_cont_proc1 + 1
               rollback work
               continue foreach
            end if
         end if
         # - Gravar Historico
         let ws.histerr = cts10g02_historico(ws.atdsrvnum    ,
                                ws.atdsrvano    ,
                                l_datmcntsrv.atldat  , #w_cts03m00.data  ,
                                l_datmcntsrv.atlhor  , #w_cts03m00.hora  ,
                                l_datmcntsrv.funmat  , #w_cts03m00.funmat,
                                "** CTS35M00-CARGA CONTINGENCIA **",
                                "","","","")
         if l_aux.msg_erro is not null then
            let ws.histerr = cts10g02_historico(ws.atdsrvnum    ,
                                 ws.atdsrvano    ,
                                 l_datmcntsrv.atldat  , #w_cts03m00.data  ,
                                 l_datmcntsrv.atlhor  , #w_cts03m00.hora  ,
                                 l_datmcntsrv.funmat  , #w_cts03m00.funmat,
                                 l_aux.msg_erro,
                                 "","","","")
         end if
         if l_datmcntsrv.obstxt is not null and
            l_datmcntsrv.obstxt <> " "      then
            let ws.hist1 = l_datmcntsrv.obstxt[1,50]
            let ws.hist2 = l_datmcntsrv.obstxt[51,100]
            let ws.hist3 = l_datmcntsrv.obstxt[101,150]
            let ws.hist4 = l_datmcntsrv.obstxt[151,200]
            let ws.hist5 = l_datmcntsrv.obstxt[201,250]

            let ws.histerr = cts10g02_historico
                             (ws.atdsrvnum    ,
                              ws.atdsrvano    ,
                              l_datmcntsrv.atddat  , #w_cts03m00.data  ,
                              l_datmcntsrv.atdhor  , #w_cts03m00.hora  ,
                              l_datmcntsrv.funmat  , #w_cts03m00.funmat,
                              ws.hist1,ws.hist2,ws.hist3,
                              ws.hist4,ws.hist5)
         end if
         #-- Grava etapa do servico
         if ws.atdetpcod <> 1 then  # gera etapa liberado

            call cts35m00_insere_etapa(ws.atdsrvnum,
                                       ws.atdsrvano,
                                       1, # ---> ATDETPCOD
                                       l_datmcntsrv.atldat,
                                       l_datmcntsrv.atlhor,
                                       l_datmcntsrv.empcod,
                                       l_datmcntsrv.funmat,
                                       "",
                                       "",
                                       "",
                                       "")
                 returning l_ins_etapa

            if l_ins_etapa <> 0 then
               output to report cts35m00_rel_proc1
                       (l_datmcntsrv.seqreg,
                        l_datmcntsrv.seqregcnt,
                        l_datmcntsrv.c24astcod,
                        l_datmcntsrv.atdsrvorg,
                        ws.atdsrvnum,
                        ws.atdsrvano,
                        l_datmcntsrv.dstsrvnum,
                        l_datmcntsrv.dstsrvano,
                        l_datmcntsrv.ciaempcod,
                        l_datmcntsrv.atldat,
                        l_datmcntsrv.atlhor,
                        l_ins_etapa,
                       "Erro ao chamar a funcao cts35m00_insere_etapa() - 4")
               let m_cont_proc1 = m_cont_proc1 + 1
               rollback work
               continue foreach
            end if
         end if


         if ws.atdetpcod = 1 then
         	  let ws.empcod = l_datmcntsrv.empcod
         else # ACIONAMENTO
            if l_datmcntsrv.h24ctloprempcod is null then
            	  let ws.empcod = 1
         	  else
         	      let ws.empcod = l_datmcntsrv.h24ctloprempcod
         	  end if
         end if

         call cts35m00_insere_etapa(ws.atdsrvnum,
                                    ws.atdsrvano,
                                    ws.atdetpcod,
                                    l_datmcntsrv.acndat,
                                    l_datmcntsrv.acnhor,
                                    ws.empcod,
                                    l_datmcntsrv.c24opemat,
                                    l_datmcntsrv.atdprscod,
                                    l_datmcntsrv.srrcoddig,
                                    l_socvclcod,
                                    l_datmcntsrv.srrabvnom)
         returning l_ins_etapa

         if l_ins_etapa <> 0 then
            output to report cts35m00_rel_proc1
                         (l_datmcntsrv.seqreg,
                          l_datmcntsrv.seqregcnt,
                          l_datmcntsrv.c24astcod,
                          l_datmcntsrv.atdsrvorg,
                          ws.atdsrvnum,
                          ws.atdsrvano,
                          l_datmcntsrv.dstsrvnum,
                          l_datmcntsrv.dstsrvano,
                          l_datmcntsrv.ciaempcod,
                          l_datmcntsrv.atldat,
                          l_datmcntsrv.atlhor,
                          l_ins_etapa,
                          "Erro ao chamar a funcao cts35m00_insere_etapa() - 5")
            let m_cont_proc1 = m_cont_proc1 + 1
            rollback work
            continue foreach
         end if
         # -- VERIFICA SE SERVI�O FOI CANCELADO:
         if l_datmcntsrv.cnlflg = "S" then
            if l_datmcntsrv.acndat is  null and   #servi�o nao acionado
               l_datmcntsrv.acnhor is  null then
               # servico do ifx nao acionado na contingencia
               # flag "S" para nao aparecer no radio.
               whenever error continue
               execute p_cts35m00_018 using ws.atdsrvnum,ws.atdsrvano
               whenever error stop
               if sqlca.sqlcode <> 0 then
                  output to report cts35m00_rel_proc1
                                 (l_datmcntsrv.seqreg,
                                  l_datmcntsrv.seqregcnt,
                                  l_datmcntsrv.c24astcod,
                                  l_datmcntsrv.atdsrvorg,
                                  ws.atdsrvnum,
                                  ws.atdsrvano,
                                  l_datmcntsrv.dstsrvnum,
                                  l_datmcntsrv.dstsrvano,
                                  l_datmcntsrv.ciaempcod,
                                  l_datmcntsrv.atldat,
                                  l_datmcntsrv.atlhor,
                                  sqlca.sqlcode,
                                 "Erro de UPDATE na tabela datmservico - 2")
                  let m_cont_proc1 = m_cont_proc1 + 1
                  rollback work
                  continue foreach
               end if
            end if


            call cts35m00_insere_etapa(ws.atdsrvnum,
                                       ws.atdsrvano,
                                       5,  # ---> ATDETPCOD
                                       l_datmcntsrv.cnldat,
                                       l_datmcntsrv.cnlhor,
                                       1,  # EMPCOD
                                       l_datmcntsrv.cnlmat,
                                       l_datmcntsrv.atdprscod,
                                       l_datmcntsrv.srrcoddig,
                                       l_socvclcod,
                                       l_datmcntsrv.srrabvnom)
                 returning l_ins_etapa

            if l_ins_etapa <> 0 then
               output to report cts35m00_rel_proc1
                    (l_datmcntsrv.seqreg,
                     l_datmcntsrv.seqregcnt,
                     l_datmcntsrv.c24astcod,
                     l_datmcntsrv.atdsrvorg,
                     ws.atdsrvnum,
                     ws.atdsrvano,
                     l_datmcntsrv.dstsrvnum,
                     l_datmcntsrv.dstsrvano,
                     l_datmcntsrv.ciaempcod,
                     l_datmcntsrv.atldat,
                     l_datmcntsrv.atlhor,
                     l_ins_etapa,
                     "Erro ao chamar a funcao cts35m00_insere_etapa() - 6")
                     let m_cont_proc1 = m_cont_proc1 + 1
               rollback work
               continue foreach
            end if
         end if
         whenever error continue
         # atualiza "S" no campo prcflg
         execute p_cts35m00_028 using ws.atdsrvnum,
                                    ws.atdsrvano,
                                    l_datmcntsrv.seqreg
         whenever error stop
         if sqlca.sqlcode <> 0 then
            output to report cts35m00_rel_proc1
                                (l_datmcntsrv.seqreg,
                                 l_datmcntsrv.seqregcnt,
                                 l_datmcntsrv.c24astcod,
                                 l_datmcntsrv.atdsrvorg,
                                 ws.atdsrvnum,
                                 ws.atdsrvano,
                                 l_datmcntsrv.dstsrvnum,
                                 l_datmcntsrv.dstsrvano,
                                 l_datmcntsrv.ciaempcod,
                                 l_datmcntsrv.atldat,
                                 l_datmcntsrv.atlhor,
                                 sqlca.sqlcode,
                                "Erro de UPDATE na tabela datmcntsrv")
            let m_cont_proc1 = m_cont_proc1 + 1
            rollback work
            continue foreach
         end if

         let l_datmcntsrv.atdsrvnum = ws.atdsrvnum
         let l_datmcntsrv.atdsrvano = ws.atdsrvano
      end if


      # Verifica se o veiculo e caminh�o
      let l_camflg = "N"
      if l_datmcntsrv.vclcamtip is not null and
         l_datmcntsrv.vclcamtip <> " " then
         let l_camflg = "S"
      end if

      #-----------------------------------------------
      # Aciona Servico automaticamente
      #-----------------------------------------------
      if (l_datmcntsrv.cnlflg = "S")
         or (l_datmcntsrv.atdprscod is not null and l_datmcntsrv.atdprscod <> 0) then
         # CANCELADO ou ACIONADO
         # flag de finalizacao = "S" para nao aparecer no radio.
         whenever error continue
            execute p_cts35m00_018 using ws.atdsrvnum,ws.atdsrvano
         whenever error stop
      else
         # --VERIFICA SE SERVICO E INTERNET OU GPS E SE ESTA ATIVO
         # --RETORNA TRUE PARA ACIONAMENTO E FALSE PARA NAO ACIONAMENTO
         if cts34g00_acion_auto (ws.atdsrvorg,
                                 l_datmcntsrv.ocrcidnom,
                                 l_datmcntsrv.ocrufdcod) then

            # --FUNCAO CTS34G00_ACION_AUTO VERIFICOU QUE PARAMETRIZACAO PARA ORIGEM
            # --DO SERVICO ESTA OK
            # --CHAMAR FUNCAO PARA VALIDAR REGRAS GERAIS SE UM SERVICO SERA ACIONADO
            # --AUTOMATICAMENTE OU NAO E ATUALIZAR DATMSERVICO
            call   cts40g12_regras_aciona_auto (ws.atdsrvorg,
                                                l_datmcntsrv.c24astcod,
                                                ws.asitipcod,
                                                l_datmcntsrv.ocrlcllttnum,
                                                l_datmcntsrv.ocrlcllgnnum,
                                                "N",
                                                "N",
                                                l_datmcntsrv.atdsrvnum,
                                                l_datmcntsrv.atdsrvano,
                                                " ",
                                                l_datmcntsrv.vclmoddigcod,
                                                l_camflg)
               returning l_aciona
         end if
      end if

      commit work
      # Ponto de acesso apos a gravacao do laudo
      call cts00g07_apos_grvlaudo_sin(l_datmcntsrv.atdsrvnum,
                                      l_datmcntsrv.atdsrvano,
                                      0) # nao sincroniza AW

      # Solicita atualizacao da informa��o de acionamento caso o AcionamentoWeb estiver ativo
      if ctx34g00_ver_acionamentoWEB(2) then
         call ctx34g02_carga_contingencia(l_datmcntsrv.atdsrvnum,
                                          l_datmcntsrv.atdsrvano)

         call ctx34g02_atualizacaoservico(l_datmcntsrv.atdsrvnum,
                                          l_datmcntsrv.atdsrvano)
      end if

      call cts17m11_notificaContingencia(l_datmcntsrv.atdsrvnum,
                                         l_datmcntsrv.atdsrvano)
      # Atualizo os Contadores
      call cts35m00_atualiza_contador("totreg",l_totreg)
      call cts35m00_atualiza_contador("totsrvifx",l_totsrvifx)
      call cts35m00_atualiza_contador("totsrvctg",l_totsrvctg)
      call cts35m00_atualiza_contador("achei",l_achei)
      call cts35m00_atualiza_contador("nachei",l_nachei)
   end foreach
   close c_cts35m00_001

   #---------------------------------------------------------------------
   # FUNCAO RESPONSAVEL POR EXECUTAR A ATUALIZACAO DA FROTA (2� PROCESSO)
   #---------------------------------------------------------------------

   # So realiza a atualizacaoo da frota quando o AcionamentoWeb estiver desativado
   if not ctx34g00_ver_acionamentoWEB(2) then
      begin work
      let l_processo_ok = cts35m00_2_processo(l_socvclcod)
      if l_processo_ok = false then
         rollback work
      else
         commit work
      end if
   end if

   #--------------------------------------------------------------------------
   # FUNCAO RESPONSAVEL POR EXECUTAR A ATUALIZACAO DAS MENSAGENS E LOGS
   #--------------------------------------------------------------------------

   # So realiza a atualizacaoo das mensagens e logs quando o AcionamentoWeb estiver desativado
   if not ctx34g00_ver_acionamentoWEB(2) then
      call cts35m00_3e4_processo()
   end if

   let l_fim = current

   let l_tempo_total = (l_fim - l_inicio)

   finish report cts35m00_rel_proc1
   finish report cts35m00_rel_proc2
   finish report cts35m00_rel_proc3
   finish report cts35m00_rel_proc4

   #--------------------------------------------------
   # ENVIA OS EMAILS REFERENTE AOS RELATORIOS DE ERROS
   #--------------------------------------------------
   if m_cont_proc1 > 0 then
      call cts35m00_email_rel("CTS35M00",
                              "Relatorio de Erros da Contingencia - Processo 1",
                               m_arq_proc1)
   end if

   if m_cont_proc2 > 0 then
      call cts35m00_email_rel("CTS35M00",
                              "Relatorio de Erros da Contingencia - Processo 2",
                               m_arq_proc2)
   end if

   if m_cont_proc3 > 0 then
      call cts35m00_email_rel("CTS35M00",
                              "Relatorio de Erros da Contingencia - Processo 3",
                               m_arq_proc3)
   end if
   if m_cont_proc4 > 0 then
      call cts35m00_email_rel("CTS35M00",
                              "Relatorio de Erros da Contingencia - Processo 4",
                               m_arq_proc4)
   end if

   let l_comando = "rm -f rel_erros_processo1.xls rel_erros_processo2.xls rel_erros_processo3.xls rel_erros_processo4.xls"
   run l_comando

   let ws.msglin1 = "TOTAL REG. LIDOS.......: ", l_totreg    using "<<<<&" clipped
   let ws.msglin2 = "TOT. SERV. IFX P/CTG...: ", l_totsrvifx using "<<<<&" clipped
   let ws.msglin3 = "TOT. SERV. CTG P/IFX...: ", l_totsrvctg using "<<<<&" clipped
   let ws.msglin4 = "C/DOCTO................: ", l_achei     using "<<<<&", "<br>",
                    "S/DOCTO................: ", l_nachei    using "<<<<&", "<br>", "<br>",
                    "HORA DO INICIO DA CARGA: ", l_inicio,                  "<br>",
                    "HORA DO FIM DA CARGA...: ", l_fim,                     "<br>",
                    "TEMPO TOTAL DA CARGA...: ", l_tempo_total clipped    , "<br>"
   {if lr_temp.flag then

      call cts35m00_seleciona_temp()

      open ccts35m00_temp

      foreach ccts35m00_temp into lr_temp.c24astcod ,
                                  lr_temp.cont

        let ws.msglin5 = ws.msglin5 clipped, "\n", "ASSUNTO ", lr_temp.c24astcod clipped           ,
                                             "............: ", lr_temp.cont using "<<<<<&&" clipped ,
                                             " REGISTRO(S)"

        let lr_temp.total = lr_temp.total +  lr_temp.cont

      end foreach

      let ws.msglin5 = ws.msglin5 clipped, "\n\n", "TOTAL..................: ",
                       lr_temp.total using "<<<<<&&" clipped, " REGISTRO(S)"

   end if}

   let l_msg_final = ws.msglin1  clipped, "<br>",
                     ws.msglin2  clipped, "<br>",
                     ws.msglin3  clipped, "<br>",
                     ws.msglin4  clipped, "<br>",
                                          "<br>",
                     ws.msglin5  clipped, "<br><br>",
                     ws.msglin6  clipped

   let l_assunto = "FIM DA CARGA DA CONTINGENCIA -> AMBIENTE DE ", l_ambiente
   ---> Nilo / Ruiz - Trata ambiente - 230408
   if not cty42g00_online() then
       let l_status = cts35m00_envia_email(l_assunto, l_msg_final,l_ambiente)
   end if

   let ws.msglin4 = null
   let ws.msglin4 = "C/DOCTO......: ", l_achei  using "<<<<&",
                    "S/DOCTO......: ", l_nachei using "<<<<&" clipped
   call cts35m00_deleta_contador()

   if not cty42g00_valida() then
      call cts08g01("C","S", ws.msglin1, ws.msglin2, ws.msglin3, ws.msglin4)
           returning ws.confirma
   end if
   if not cty42g00_online() then

      --[atualiza chave de acesso PSOCNTCARGA na datkgeral p/ liberar o IFX.]---
      whenever error continue
      execute p_cts35m00_049
      whenever error stop
      if sqlca.sqlcode = 0 then
         error "*****  I N F O R M I X    L I B E R A D O ******"
      end if
   end if
   if cty42g00_automatico() then
       #----------------------------------------
       # Atualiza Processo para Finalizado
       #----------------------------------------
       call cty42g00_atualiza("N")
   end if
   --[Faz a carga do Furto e Roubo]--
     call cts35m05(1)
   whenever error stop
    execute p_cts35m00_065 using l_atualizacao
   whenever error continue

end function

#---------------------------------------#
function cts35m00_2_processo(l_socvclcod)
#---------------------------------------#

  # ---FUNCAO RESPONSAVEL POR EXECUTAR O SEGUNDO PROCESSO DA CARGA
  # ---DA CONTINGENCIA, QUE E A ATUALIZACAO DA FROTA

  define l_socvclcod      like datkveiculo.socvclcod

  define lr_datmcntsttvcl record
         seqreg           like datmcntsttvcl.seqreg,
         atdvclsgl        like datmcntsttvcl.atdvclsgl,
         c24atvcod        like datmcntsttvcl.c24atvcod,
         prcflg           like datmcntsttvcl.prcflg,
         seqregcnt        like datmcntsttvcl.seqregcnt,
         atdsrvnum        like datmcntsttvcl.atdsrvnum,
         atdsrvano        like datmcntsttvcl.atdsrvano,
         gpsufdcod        like datmcntsttvcl.gpsufdcod,
         gpscidnom        like datmcntsttvcl.gpscidnom,
         gpsbrrnom        like datmcntsttvcl.gpsbrrnom,
         gpsendzon        like datmcntsttvcl.gpsendzon,
         gpslclltt        like datmcntsttvcl.gpslclltt,
         gpslcllgt        like datmcntsttvcl.gpslcllgt,
         qthufdcod        like datmcntsttvcl.qthufdcod,
         qthcidnom        like datmcntsttvcl.qthcidnom,
         qthbrrnom        like datmcntsttvcl.qthbrrnom,
         qthendzon        like datmcntsttvcl.qthendzon,
         qthlclltt        like datmcntsttvcl.qthlclltt,
         qthlcllgt        like datmcntsttvcl.qthlcllgt,
         qtiufdcod        like datmcntsttvcl.qtiufdcod,
         qticidnom        like datmcntsttvcl.qticidnom,
         qtibrrnom        like datmcntsttvcl.qtibrrnom,
         qtiendzon        like datmcntsttvcl.qtiendzon,
         qtilclltt        like datmcntsttvcl.qtilclltt,
         qtilcllgt        like datmcntsttvcl.qtilcllgt
  end record

  define l_processo_ok    smallint,
         l_sqlcode        integer,
         l_total          integer,
         l_cont           integer

  #------------------------------
  # INICIALIZACAO DAS VARIAVEIS
  #------------------------------

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_processo_ok = null
  let l_sqlcode     = null
  let l_total       = null
  let l_cont        = 0

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  initialize lr_datmcntsttvcl.*  to  null

  initialize lr_datmcntsttvcl to null

  let l_processo_ok = true

  # BUSCA O TOTAL DE REGISTROS
  open c_cts35m00_022
  fetch c_cts35m00_022 into l_total
  close c_cts35m00_022

  #-----------------------------------
  # ATUALIZAR FROTA - SEGUNDO PROCESSO
  #-----------------------------------
  error "Atualizando Frota, favor aguardar..." sleep 2

  open c_cts35m00_002
  foreach c_cts35m00_002 into lr_datmcntsttvcl.seqreg,
                            lr_datmcntsttvcl.atdvclsgl,
                            lr_datmcntsttvcl.c24atvcod,
                            lr_datmcntsttvcl.prcflg,
                            lr_datmcntsttvcl.seqregcnt,
                            lr_datmcntsttvcl.atdsrvnum,
                            lr_datmcntsttvcl.atdsrvano,
                            lr_datmcntsttvcl.gpsufdcod,
                            lr_datmcntsttvcl.gpscidnom,
                            lr_datmcntsttvcl.gpsbrrnom,
                            lr_datmcntsttvcl.gpsendzon,
                            lr_datmcntsttvcl.gpslclltt,
                            lr_datmcntsttvcl.gpslcllgt,
                            lr_datmcntsttvcl.qthufdcod,
                            lr_datmcntsttvcl.qthcidnom,
                            lr_datmcntsttvcl.qthbrrnom,
                            lr_datmcntsttvcl.qthendzon,
                            lr_datmcntsttvcl.qthlclltt,
                            lr_datmcntsttvcl.qthlcllgt,
                            lr_datmcntsttvcl.qtiufdcod,
                            lr_datmcntsttvcl.qticidnom,
                            lr_datmcntsttvcl.qtibrrnom,
                            lr_datmcntsttvcl.qtiendzon,
                            lr_datmcntsttvcl.qtilclltt,
                            lr_datmcntsttvcl.qtilcllgt

     let l_cont = l_cont + 1

     if cty42g00_automatico() then
         display "ATENCAO - REGISTROS LIDOS - FROTA: ", l_cont using "<<<<<<<<&",
                 " DE: ", l_total using "<<<<<<<<&"
     else
         error "ATENCAO - REGISTROS LIDOS - FROTA: ", l_cont using "<<<<<<<<&",
               " DE: ", l_total using "<<<<<<<<&"
     end if
     open c_cts35m00_003 using lr_datmcntsttvcl.atdvclsgl
     fetch c_cts35m00_003 into l_socvclcod

     if sqlca.sqlcode <> 0 then
        let l_socvclcod = null
     end if

     close c_cts35m00_003

     #-----------------------------------
     # VERIFICA ONDE O SERVICO FOI GERADO
     #-----------------------------------
     if lr_datmcntsttvcl.seqregcnt is not null then
        # --> SERVICO GERADO NA CONTINGENCIA

        # BUSCA atdsrvnum e atdsrvano DA TABELA datmcntsrv
        open c_cts35m00_004 using lr_datmcntsttvcl.seqregcnt
        fetch c_cts35m00_004 into lr_datmcntsttvcl.atdsrvnum,
                                lr_datmcntsttvcl.atdsrvano
        close c_cts35m00_004
     end if

     let l_sqlcode = cts33g01_posfrota(l_socvclcod,
                                       "N",
                                       lr_datmcntsttvcl.gpsufdcod,
                                       lr_datmcntsttvcl.gpscidnom,
                                       lr_datmcntsttvcl.gpsbrrnom,
                                       lr_datmcntsttvcl.gpsendzon,
                                       lr_datmcntsttvcl.gpslclltt,
                                       lr_datmcntsttvcl.gpslcllgt,
                                       lr_datmcntsttvcl.qthufdcod,
                                       lr_datmcntsttvcl.qthcidnom,
                                       lr_datmcntsttvcl.qthbrrnom,
                                       lr_datmcntsttvcl.qthendzon,
                                       lr_datmcntsttvcl.qthlclltt,
                                       lr_datmcntsttvcl.qthlcllgt,
                                       today,
                                       current hour to minute,
                                       lr_datmcntsttvcl.c24atvcod,
                                       lr_datmcntsttvcl.atdsrvnum,
                                       lr_datmcntsttvcl.atdsrvano)
     if l_sqlcode <> 0 then
        #let l_processo_ok = false
        let m_cont_proc2  = m_cont_proc2 + 1
        output to report cts35m00_rel_proc2(lr_datmcntsttvcl.seqregcnt,
                                  lr_datmcntsttvcl.atdsrvnum,
                                  lr_datmcntsttvcl.atdsrvano,
                                  l_sqlcode,
                                 "Erro ao chamar a funcao cts33g01_posfrota()")
        #exit foreach
        continue foreach
     end if

     #-----------------------------------------
     # VERIFICA SE ATUALIZA A TABELA datmfrtpos
     #-----------------------------------------
     if lr_datmcntsttvcl.qtilclltt is not null and
        lr_datmcntsttvcl.qtilclltt <> " "      then
        whenever error continue
        execute p_cts35m00_006 using lr_datmcntsttvcl.qtiufdcod,
                                   lr_datmcntsttvcl.qticidnom,
                                   lr_datmcntsttvcl.qtibrrnom,
                                   lr_datmcntsttvcl.qtiendzon,
                                   lr_datmcntsttvcl.qtilclltt,
                                   lr_datmcntsttvcl.qtilcllgt,
                                   l_socvclcod
        whenever error stop

        if sqlca.sqlcode <> 0 then
           output to report cts35m00_rel_proc2(lr_datmcntsttvcl.seqregcnt,
                                      lr_datmcntsttvcl.atdsrvnum,
                                      lr_datmcntsttvcl.atdsrvano,
                                      sqlca.sqlcode,
                                     "Erro de UPDATE na tabela datmfrtpos")
           #let l_processo_ok = false
           let m_cont_proc2  = m_cont_proc2 + 1
           #exit foreach
           continue foreach
        end if
     end if

     initialize lr_datmcntsttvcl to null

  end foreach
  close c_cts35m00_002

  # -> EXCLUI OS DADOS DA TABELA datmcntsttvcl
  whenever error continue
  execute p_cts35m00_045
  whenever error stop

  if sqlca.sqlcode <> 0 then
     output to report cts35m00_rel_proc2("",
                                         "",
                                         "",
                                         sqlca.sqlcode,
                                         "Erro de DELETE na tabela datmcntsttvcl")
     #let l_processo_ok = false
     let m_cont_proc2  = m_cont_proc2 + 1
  end if

  return l_processo_ok

end function

#------------------------------#
function cts35m00_3e4_processo()
#------------------------------#

  # ---FUNCAO RESPONSAVEL POR EXECUTAR O TERCEIRO PROCESSO DA CARGA
  # ---DA CONTINGENCIA, QUE E A ATUALIZACAO DAS MENSAGENS

  define lr_datmcntmsgctr record
         mdtmsgnum        like datmcntmsgctr.mdtmsgnum,
         mdtmsgorgcod     like datmcntmsgctr.mdtmsgorgcod,
         mdtcod           like datmcntmsgctr.mdtcod,
         mdtmsgstt        like datmcntmsgctr.mdtmsgstt,
         mdtmsgavstip     like datmcntmsgctr.mdtmsgavstip,
         mdtmsgtxtseq     like datmcntmsgctr.mdtmsgtxtseq,
         mdtmsgtxt        like datmcntmsgctr.mdtmsgtxt,
         atdsrvnum        like datmcntmsgctr.atdsrvnum,
         atdsrvano        like datmcntmsgctr.atdsrvano,
         seqregcnt        like datmcntmsgctr.seqregcnt,
         prcflg           like datmcntmsgctr.prcflg,
         novmsgflg        like datmcntmsgctr.novmsgflg
  end record

  define lr_datmcntlogctr record
         mdtmsgnum        like datmcntlogctr.mdtmsgnum,
         mdtmsgstt        like datmcntlogctr.mdtmsgstt,
         atldat           like datmcntlogctr.atldat,
         atlhor           like datmcntlogctr.atlhor,
         atlemp           like datmcntlogctr.atlemp,
         atlmat           like datmcntlogctr.atlmat,
         atlusrtip        like datmcntlogctr.atlusrtip
  end record

  define l_processo_ok    smallint,
         l_max_mdtlogseq  integer,
         l_mdtmsgnumifx   like datmcntmsgctr.mdtmsgnum,
         l_total          integer,
         l_cont           integer

  #------------------------------
  # INICIALIZACAO DAS VARIAVEIS
  #------------------------------

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let l_processo_ok   =  null
        let l_max_mdtlogseq =  null
        let l_total         = null
        let l_cont          = 0

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  lr_datmcntmsgctr.*  to  null

        initialize  lr_datmcntlogctr.*  to  null

  initialize lr_datmcntmsgctr,
             lr_datmcntlogctr to null

  let l_processo_ok   = true
  let l_max_mdtlogseq = null

  # BUSCA O TOTAL DE REGISTROS
  open c_cts35m00_023
  fetch c_cts35m00_023 into l_total
  close c_cts35m00_023

  #----------------------------------------
  # ATUALIZAR MENSAGENS - TERCEIRO PROCESSO
  #----------------------------------------
  error "Atualizando Mensagens, favor aguardar..." sleep 2

  #------------------------------------------------------------------
  # ACESSA TODOS O REGISTROS DA TABELA datmcntmsgctr COM prcflg = 'N'
  #------------------------------------------------------------------
  open c_cts35m00_005
  foreach c_cts35m00_005 into lr_datmcntmsgctr.mdtmsgnum,
                            lr_datmcntmsgctr.mdtmsgorgcod,
                            lr_datmcntmsgctr.mdtcod,
                            lr_datmcntmsgctr.mdtmsgstt,
                            lr_datmcntmsgctr.mdtmsgavstip,
                            lr_datmcntmsgctr.mdtmsgtxtseq,
                            lr_datmcntmsgctr.mdtmsgtxt,
                            lr_datmcntmsgctr.atdsrvnum,
                            lr_datmcntmsgctr.atdsrvano,
                            lr_datmcntmsgctr.seqregcnt,
                            lr_datmcntmsgctr.prcflg,
                            lr_datmcntmsgctr.novmsgflg

      let l_cont = l_cont + 1

      if cty42g00_automatico() then
         display "ATENCAO - REGISTROS LIDOS - MENSAGENS: ", l_cont using "<<<<<<<<&",
                 " DE: ", l_total using "<<<<<<<<&"
     else
         error "ATENCAO - REGISTROS LIDOS - MENSAGENS: ", l_cont using "<<<<<<<<&",
               " DE: ", l_total using "<<<<<<<<&"
     end if

     if lr_datmcntmsgctr.novmsgflg = "S" then
        #----------------------------
        # INSERE NA TABELA datmmdtmsg
        #----------------------------
        #CT: 80311643
        begin work
        whenever error continue
        execute p_cts35m00_008 using lr_datmcntmsgctr.mdtmsgorgcod,
                                   lr_datmcntmsgctr.mdtcod,
                                   lr_datmcntmsgctr.mdtmsgstt,
                                   lr_datmcntmsgctr.mdtmsgavstip

        let l_mdtmsgnumifx = sqlca.sqlerrd[2] # Raji

        whenever error stop

        if sqlca.sqlcode <> 0 then
           output to report cts35m00_rel_proc3(lr_datmcntmsgctr.seqregcnt,
                                           lr_datmcntmsgctr.novmsgflg,
                                           lr_datmcntmsgctr.mdtmsgnum,
                                           lr_datmcntmsgctr.atdsrvnum,
                                           lr_datmcntmsgctr.atdsrvano,
                                           sqlca.sqlcode,
                                          "Erro de INSERT na tabela datmmdtmsg")
           let m_cont_proc3 = m_cont_proc3 + 1
           #let l_processo_ok = false
           execute p_cts35m00_046 using lr_datmcntmsgctr.mdtmsgnum
           #CT: 80311643
           rollback work
           #exit foreach
           continue foreach
        else
           #CT: 80311643
           commit work
        end if

        #-------------------------------
        # INSERE NA TABELA datmmdtmsgtxt
        #-------------------------------
      # let lr_datmcntmsgctr.mdtmsgnum = sqlca.sqlerrd[2]
        #CT: 80311643
        begin work

        whenever error continue
        execute p_cts35m00_009 using l_mdtmsgnumifx,
                                   lr_datmcntmsgctr.mdtmsgtxtseq,
                                   lr_datmcntmsgctr.mdtmsgtxt
        whenever error stop

        if sqlca.sqlcode <> 0 then
           output to report cts35m00_rel_proc3(lr_datmcntmsgctr.seqregcnt,
                                        lr_datmcntmsgctr.novmsgflg,
                                        lr_datmcntmsgctr.mdtmsgnum,
                                        lr_datmcntmsgctr.atdsrvnum,
                                        lr_datmcntmsgctr.atdsrvano,
                                        sqlca.sqlcode,
                                       "Erro de INSERT na tabela datmmdtmsgtxt")
           let m_cont_proc3 = m_cont_proc3 + 1
           #let l_processo_ok = false
           execute p_cts35m00_046 using lr_datmcntmsgctr.mdtmsgnum
           #CT: 80311643
           rollback work
           #exit foreach
           continue foreach
        else
           #CT: 80311643
           commit work
        end if

        #-----------------------------------
        # VERIFICA ONDE O SERVICO FOI GERADO
        #-----------------------------------
        if lr_datmcntmsgctr.atdsrvnum is null then
                   # -> SERVICO GERADO NA CONTINGENCIA

           #----------------------------------------------------
           # BUSCA atdsrvnum e atdsrvano DA TABELA datmcntsrv
           #----------------------------------------------------
           open c_cts35m00_004 using lr_datmcntmsgctr.seqregcnt
           fetch c_cts35m00_004 into lr_datmcntmsgctr.atdsrvnum,
                                   lr_datmcntmsgctr.atdsrvano
           close c_cts35m00_004

        end if

        #----------------------------
        # INSERE NA TABELA datmmdtsrv
        #----------------------------
        #CT: 80311643
        begin work
        whenever error continue
        execute p_cts35m00_010 using l_mdtmsgnumifx,
                                   lr_datmcntmsgctr.atdsrvnum,
                                   lr_datmcntmsgctr.atdsrvano
        whenever error stop

        if sqlca.sqlcode <> 0 then
           output to report cts35m00_rel_proc3(lr_datmcntmsgctr.seqregcnt,
                                          lr_datmcntmsgctr.novmsgflg,
                                          lr_datmcntmsgctr.mdtmsgnum,
                                          lr_datmcntmsgctr.atdsrvnum,
                                          lr_datmcntmsgctr.atdsrvano,
                                          sqlca.sqlcode,
                                         "Erro de INSERT na tabela datmmdtsrv")
           let m_cont_proc3 = m_cont_proc3 + 1
           #let l_processo_ok = false
           execute p_cts35m00_046 using lr_datmcntmsgctr.mdtmsgnum
           #CT: 80311643
           rollback work
           #exit foreach
           continue foreach
        else
           #CT: 80311643
           commit work
        end if

     else
        #-----------------------------
        # ATUALIZA A TABELA datmmdtmsg
        #-----------------------------
        #CT: 80311643
        begin work
        whenever error continue
        execute p_cts35m00_014 using lr_datmcntmsgctr.mdtmsgstt,
                                   lr_datmcntmsgctr.mdtmsgnum
        whenever error stop

        if sqlca.sqlcode <> 0 then
           output to report cts35m00_rel_proc3(lr_datmcntmsgctr.seqregcnt,
                                         lr_datmcntmsgctr.novmsgflg,
                                         lr_datmcntmsgctr.mdtmsgnum,
                                         lr_datmcntmsgctr.atdsrvnum,
                                         lr_datmcntmsgctr.atdsrvano,
                                         sqlca.sqlcode,
                                        "Erro de UPDATE na tabela datmmdtmsg")
           let m_cont_proc3 = m_cont_proc3 + 1
           #let l_processo_ok = false
           execute p_cts35m00_046 using lr_datmcntmsgctr.mdtmsgnum
           #CT: 80311643
           rollback work
           #exit foreach
           continue foreach
        else
           #CT: 80311643
           commit work
        end if
     end if
     #-------------------------------
     # SE OCORREU ERRO SAI DO FOREACH
     #-------------------------------
     if l_processo_ok = false then
        exit foreach
     end if
     #--------------------------------
     # ATUALIZA A TABELA datmcntmsgctr
     #--------------------------------
     #CT: 80311643
     begin work
     whenever error continue
     execute p_cts35m00_016 using lr_datmcntmsgctr.mdtmsgnum
     whenever error stop
     if sqlca.sqlcode <> 0 then
        output to report cts35m00_rel_proc3(lr_datmcntmsgctr.seqregcnt,
                                      lr_datmcntmsgctr.novmsgflg,
                                      lr_datmcntmsgctr.mdtmsgnum,
                                      lr_datmcntmsgctr.atdsrvnum,
                                      lr_datmcntmsgctr.atdsrvano,
                                      sqlca.sqlcode,
                                     "Erro de UPDATE na tabela datmcntmsgctr")
        let m_cont_proc3 = m_cont_proc3 + 1
        #let l_processo_ok = false
        execute p_cts35m00_046 using lr_datmcntmsgctr.mdtmsgnum
        #CT: 80311643
        rollback work
        #exit foreach
        continue foreach
     else
        #CT: 80311643
        commit work
     end if

     initialize lr_datmcntmsgctr, lr_datmcntlogctr to null
  # atualiza datmcntmsgctr.prcflg = S where mdtmsgnum=lr_datmcntmsgctr.mdtmsgnum
  end foreach
  close c_cts35m00_005

  # BUSCA O TOTAL DE REGISTROS
  open c_cts35m00_024
  fetch c_cts35m00_024 into l_total
  close c_cts35m00_024

  let l_cont = 0

  #----------------------------------------
  # ATUALIZAR lOGS - QUARTO PROCESSO
  #----------------------------------------
  error "Atualizando Mensagens de Log, favor aguardar..." sleep 2

  #------------------------------------------------------------------
  # ACESSA TODOS OS REGISTROS DA TABELA datmcntlogctr COM prcflg = 'N'
  # ACESSA TODOS OS REGISTROS DAS TABELAS datmcntlogctr E datmcntmsgctr
  #----------------------------------------------------------------------
  open c_cts35m00_006
  foreach c_cts35m00_006 into lr_datmcntlogctr.mdtmsgnum,
                            lr_datmcntlogctr.mdtmsgstt,
                            lr_datmcntlogctr.atldat,
                            lr_datmcntlogctr.atlhor,
                            lr_datmcntlogctr.atlemp,
                            lr_datmcntlogctr.atlmat,
                            lr_datmcntlogctr.atlusrtip,
                            lr_datmcntmsgctr.atdsrvnum,
                            lr_datmcntmsgctr.atdsrvano,
                            lr_datmcntmsgctr.seqregcnt,
                            lr_datmcntmsgctr.novmsgflg
                   #     buscar todos com datmcntlogctr.prcflg="N"

     let l_cont = l_cont + 1

     if cty42g00_automatico() then
          display "ATENCAO - REGISTROS LIDOS - LOG: ", l_cont using "<<<<<<<<&",
                  " DE: ", l_total using "<<<<<<<<&"
     else
          error "ATENCAO - REGISTROS LIDOS - LOG: ", l_cont using "<<<<<<<<&",
                " DE: ", l_total using "<<<<<<<<&"
     end if
     #---------------------------------------------
     # BUSCA A MAIOR mdtlogseq DA TABELA datmmdtlog
     #---------------------------------------------
     if lr_datmcntmsgctr.atdsrvnum  is not null then
        if lr_datmcntmsgctr.novmsgflg = "S" or
           lr_datmcntmsgctr.novmsgflg is null then
           # BUSCA ULTIMA MENSAGEM DO SERVICO datmmdtsrv
           open c_cts35m00_021 using lr_datmcntmsgctr.atdsrvnum,
                                   lr_datmcntmsgctr.atdsrvano
           fetch c_cts35m00_021 into l_mdtmsgnumifx
           close c_cts35m00_021
        else
           let l_mdtmsgnumifx = lr_datmcntlogctr.mdtmsgnum
        end if
     else
        # BUSCA atdsrvnum e atdsrvano DA TABELA datmcntsrv
        open c_cts35m00_004 using lr_datmcntmsgctr.seqregcnt
        fetch c_cts35m00_004 into lr_datmcntmsgctr.atdsrvnum,
                                lr_datmcntmsgctr.atdsrvano
        close c_cts35m00_004
        # BUSCA ULTIMA MENSAGEM DO SERVICO datmmdtsrv
        open c_cts35m00_021 using lr_datmcntmsgctr.atdsrvnum,
                                lr_datmcntmsgctr.atdsrvano
        fetch c_cts35m00_021 into l_mdtmsgnumifx
        close c_cts35m00_021

     end if
     # busca ultima sequencia da tabela datmmdtlog #
     open c_cts35m00_007 using l_mdtmsgnumifx
     fetch c_cts35m00_007 into l_max_mdtlogseq
     close c_cts35m00_007

     if l_max_mdtlogseq is null then
        let l_max_mdtlogseq = 0
     end if

     let l_max_mdtlogseq = (l_max_mdtlogseq + 1)

     #----------------------------
     # INSERE NA TABELA datmmdtlog
     #----------------------------
     #CT: 80311643
     begin work
     whenever error continue
     execute p_cts35m00_013 using l_mdtmsgnumifx,
                                l_max_mdtlogseq,
                                lr_datmcntlogctr.mdtmsgstt,
                                lr_datmcntlogctr.atldat,
                                lr_datmcntlogctr.atlhor,
                                lr_datmcntlogctr.atlemp,
                                lr_datmcntlogctr.atlmat,
                                lr_datmcntlogctr.atlusrtip
     whenever error stop

     if sqlca.sqlcode <> 0 then
        output to report cts35m00_rel_proc4(lr_datmcntmsgctr.seqregcnt,
                                       lr_datmcntmsgctr.novmsgflg,
                                       l_mdtmsgnumifx            ,
                                       lr_datmcntmsgctr.atdsrvnum,
                                       lr_datmcntmsgctr.atdsrvano,
                                       sqlca.sqlcode,
                                      "Erro de INSERT na tabela datmmdtlog")
        let m_cont_proc4 = m_cont_proc4 + 1
        #let l_processo_ok = false
        #CT: 80311643
        rollback work

        #exit foreach
        continue foreach
     else
        #CT: 80311643
        commit work
     end if
     #-----------------------------
     # ATUALIZA A TABELA datmmdtmsg
     #-----------------------------
     #CT: 80311643
     begin work
     whenever error continue
     execute p_cts35m00_014 using lr_datmcntlogctr.mdtmsgstt,
                                l_mdtmsgnumifx
     whenever error stop

     if sqlca.sqlcode <> 0 then
        output to report cts35m00_rel_proc4(lr_datmcntmsgctr.seqregcnt,
                                      lr_datmcntmsgctr.novmsgflg,
                                      lr_datmcntlogctr.mdtmsgnum,
                                      lr_datmcntmsgctr.atdsrvnum,
                                      lr_datmcntmsgctr.atdsrvano,
                                      sqlca.sqlcode,
                                     "Erro de UPDATE na tabela datmmdtmsg")
        let m_cont_proc4 = m_cont_proc4 + 1
        #let l_processo_ok = false
        #CT: 80311643
        rollback work

        #exit foreach
        continue foreach
     else
        #CT: 80311643
        commit work
     end if
     #-----------------------------------------------
     # ATUALIZA A TABELA datmcntlogctr prcflg = "S"
     #-----------------------------------------------

     #CT: 80311643
     begin work
     whenever error continue
     execute p_cts35m00_038 using lr_datmcntlogctr.mdtmsgnum
     whenever error stop
     if sqlca.sqlcode <> 0 then
        output to report cts35m00_rel_proc4(lr_datmcntmsgctr.seqregcnt,
                                      lr_datmcntmsgctr.novmsgflg,
                                      lr_datmcntlogctr.mdtmsgnum,
                                      lr_datmcntmsgctr.atdsrvnum,
                                      lr_datmcntmsgctr.atdsrvano,
                                      sqlca.sqlcode,
                                     "Erro de UPDATE na tabela datmcntlogctr")
        let m_cont_proc4 = m_cont_proc4 + 1
        #let l_processo_ok = false
        #CT: 80311643
        rollback work

        #exit foreach
        continue foreach
     else
        #CT: 80311643
        commit work
     end if

     initialize lr_datmcntlogctr to null

  end foreach
  close c_cts35m00_006

  #return l_processo_ok

end function

#--------------------------------#
function cts35m00_apolice(l_param)
#--------------------------------#

 --[ FUN��O VALIDAR APOLICE ]

 define l_param      record
        ramcod       like datmcntsrv.ramcod
       ,succod       like datmcntsrv.succod
       ,aplnumdig    like datmcntsrv.aplnumdig
       ,itmnumdig    like datmcntsrv.itmnumdig
 end record

 define l_aux        record
        msg_erro     char(40)
       ,flag         smallint
       ,apl          char(08)
       ,apldig       char(01)
       ,sucnom       like gabksuc.sucnom
       ,aplnumdig    char(09)
       ,itmnumdig    like datmcntsrv.itmnumdig
       ,ramsgl       char(15)
       ,aplint       integer
 end record

 define lr_cty05g00 record
    resultado       smallint
   ,mensagem        char(42)
   ,emsdat          like abamdoc.emsdat
   ,aplstt          like abamapol.aplstt
   ,vigfnl          like abamapol.vigfnl
   ,etpnumdig like abamapol.etpnumdig
 end record

 define lr_cty06g00 record
    resultado      smallint
   ,mensagem       char(60)
   ,sgrorg         like rsamseguro.sgrorg
   ,sgrnumdig      like rsamseguro.sgrnumdig
   ,vigfnl         like rsdmdocto.vigfnl
   ,aplstt         like rsdmdocto.edsstt
   ,prporg         like rsdmdocto.prporg
   ,prpnumdig      like rsdmdocto.prpnumdig
   ,segnumdig      like rsdmdocto.segnumdig
   ,edsnumref      like rsdmdocto.edsnumdig
 end record

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

 initialize  l_aux.*  to  null
 initialize  lr_cty05g00.*  to  null
 initialize  lr_cty06g00.*  to  null

 let l_aux.ramsgl    = "RE"
 let l_aux.aplnumdig = l_param.aplnumdig


 let l_aux.aplint = l_aux.aplnumdig / 10
 let l_aux.apl    = l_aux.aplint

 let l_aux.aplint = l_aux.aplnumdig mod 10
 let l_aux.apldig = l_aux.aplint

 --[ validar sucursal ]--
 call f_fungeral_sucursal(l_param.succod)
      returning l_aux.sucnom

 if l_aux.sucnom is null then
    let l_aux.msg_erro = "cts35m00-Sucursal nao cadastrada"
    return l_aux.msg_erro
 end if

 initialize l_aux.aplnumdig to null
 call F_FUNDIGIT_DIGAPOL(l_param.succod
                        ,l_param.ramcod
                        ,l_aux.apl)
      returning l_aux.aplnumdig

 if l_aux.aplnumdig is null  then
    let l_aux.msg_erro = "cts35m00-Apolice n�o encontrada"
    return l_aux.msg_erro
 end if

 if l_aux.aplnumdig <>     l_param.aplnumdig then
    let l_aux.msg_erro = "cts35m00-Problemas com digito da Apolice"
    return l_aux.msg_erro
 end if

 --[ Obter dados da apolice de auto ]--
 if l_param.ramcod = 31 or
    l_param.ramcod = 531 then
    call cty05g00_dados_apolice(l_param.succod
                               ,l_param.aplnumdig)
         returning lr_cty05g00.*

    if lr_cty05g00.resultado = 2 or
       lr_cty05g00.resultado = 3 or
       lr_cty05g00.emsdat is null then
       let l_aux.msg_erro = "cts35m00-",lr_cty05g00.mensagem
       return l_aux.msg_erro
    end if

    if lr_cty05g00.emsdat is null then
       let l_aux.msg_erro = "cts35m00-",lr_cty05g00.mensagem
       return l_aux.msg_erro
    end if

    if lr_cty05g00.vigfnl < today  then
       let l_aux.msg_erro = "cts35m00-Apolice Vencida"
       return l_aux.msg_erro
    end if

    if lr_cty05g00.aplstt = "C" then
       let l_aux.msg_erro = "cts35m00-Apolice Cancelada"
       return l_aux.msg_erro
    end if

    #---- valida item da apolice ----#
    call F_FUNDIGIT_DIGITO11 (l_param.itmnumdig)
         returning l_aux.itmnumdig

    if l_aux.itmnumdig  is null   then
       let l_aux.msg_erro = "cts35m00-Problemas no digito do item"
       return l_aux.msg_erro
    end if

    #-- Consistir o item na apolice --#
    call cty05g00_consiste_item(l_param.succod
                               ,l_param.aplnumdig
                               ,l_param.itmnumdig)
         returning l_aux.flag

    if l_aux.flag = 2 then
       let l_aux.msg_erro = "cts35m00-Item nao existe nesta apolice"
       return l_aux.msg_erro
    end if

    #-- Obter ultima situacao da apolice de Auto --#
    call f_funapol_ultima_situacao(l_param.succod
                                  ,l_param.aplnumdig
                                  ,l_param.itmnumdig)

         returning  g_funapol.*

    if g_funapol.resultado <> "O"   then
       let l_aux.msg_erro = "cts35m00-Ultima situacao da apl nao encontrada"
       return l_aux.msg_erro
    end if

 else
    #-- Obter dados apolice RE --#
    call cty06g00_dados_apolice(l_param.succod
                               ,l_param.ramcod
                               ,l_param.aplnumdig
                               ,l_aux.ramsgl)
         returning lr_cty06g00.*

    if lr_cty06g00.resultado = 2 or
       lr_cty06g00.resultado = 3 then
       let l_aux.msg_erro = "cts35m00-",lr_cty06g00.mensagem
       return l_aux.msg_erro
    end if

    if lr_cty06g00.aplstt is null then
       let l_aux.msg_erro = "cts35m00-Apolice de RE nao cadastrada "
       return l_aux.msg_erro
    end if
 end if

  let g_documento.succod    = l_param.succod
  let g_documento.ramcod    = l_param.ramcod
  let g_documento.aplnumdig = l_param.aplnumdig
  let g_documento.itmnumdig = l_param.itmnumdig

  return l_aux.msg_erro

end function

#------------------------------#
function cts35m00_placa(l_param)
#------------------------------#

 --[ CARGA DA CONTINGENCIA POR PLACA. ]--
 --[ FUN��O PESQUISA APOLICE POR PLACA:]--

 define l_param      record
        vcllicnum    like datmcntsrv.vcllicnum
 end record

 define l_aux        record
        msg_erro     char(40)
       ,succod       like abbmveic.succod
       ,aplnumdig    like abbmveic.aplnumdig
       ,itmnumdig    like abbmveic.itmnumdig
       ,dctnumseq    like abbmveic.dctnumseq
       ,aplstt       like abamapol.aplstt
       ,viginc       like abamapol.viginc
       ,vigfnl       like abamapol.vigfnl
       ,achou        integer
 end record



#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  l_aux.*  to  null

 if l_param.vcllicnum is not null then

    let l_aux.achou = 1

    open c_cts35m00_018 using l_param.vcllicnum
    foreach c_cts35m00_018  into l_aux.succod
                             ,l_aux.aplnumdig
                             ,l_aux.itmnumdig
                             ,l_aux.dctnumseq

       call F_FUNAPOL_ULTIMA_SITUACAO(l_aux.succod
                                     ,l_aux.aplnumdig
                                     ,l_aux.itmnumdig)
          returning g_funapol.*

       if g_funapol.resultado = "O" then

          open c_cts35m00_014 using l_aux.succod, l_aux.aplnumdig
          whenever error continue
          fetch c_cts35m00_014 into l_aux.aplstt, l_aux.viginc, l_aux.vigfnl
          whenever error stop
          close c_cts35m00_014

          if l_aux.aplstt <> "C" and
             l_aux.vigfnl >  today then
             initialize l_aux.msg_erro to null
             let g_documento.succod    = l_aux.succod
             let g_documento.ramcod    = 531
             let g_documento.aplnumdig = l_aux.aplnumdig
             let g_documento.itmnumdig = l_aux.itmnumdig
             let l_aux.achou           = 0
             exit foreach
          end if

       end if

    end foreach
    close c_cts35m00_018

  end if

  if l_aux.achou = 1 then
     let l_aux.msg_erro = "cts35m00-Apolice nao encontrada-placa"
  end if

  return l_aux.msg_erro

end function

#-------------------------------#
function cts35m00_cgccpf(l_param)
#-------------------------------#

 define l_param    record
        cgccpfnum  like datmcntsrv.cpfnum
       ,cgcord     like datmcntsrv.cgcord
       ,cpfdig     like datmcntsrv.cpfdig
       ,ramcod     like datmcntsrv.ramcod
       ,ramgrpcod  like gtakram.ramgrpcod
 end record

 define l_aux        record
        msg_erro     char(40)
       ,succod       like abbmveic.succod
       ,aplnumdig    like abbmveic.aplnumdig
       ,itmnumdig    like abbmveic.itmnumdig
       ,aplstt       like abamapol.aplstt
       ,viginc       like abamapol.viginc
       ,vigfnl       like abamapol.vigfnl
       ,pestip       char(01)
       ,segnumdig    like gsakseg.segnumdig
       ,prporg       like rsdmdocto.prporg
       ,prpnumdig    like rsdmdocto.prpnumdig
       ,sgrorg       like rsdmdocto.sgrorg
       ,sgrnumdig    like rsdmdocto.sgrnumdig
       ,dctnumseq    like rsdmdocto.dctnumseq
       ,ramcod       like datmcntsrv.ramcod
       ,itmsttatu    like abbmitem.itmsttatu
       ,cgccpfdig    like datmcntsrv.cpfdig
 end record



#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  l_aux.*  to  null

 if l_param.cgcord > 0 then
   let l_aux.pestip = "J"
 else
   let l_aux.pestip = "F"
 end if

 if l_aux.pestip =  "J"    then
    call F_FUNDIGIT_DIGITOCGC(l_param.cgccpfnum
                             ,l_param.cgcord)
         returning l_aux.cgccpfdig
 else
    call F_FUNDIGIT_DIGITOCPF(l_param.cgccpfnum)
         returning l_aux.cgccpfdig
 end if

 if l_aux.cgccpfdig is null or
    l_param.cpfdig <> l_aux.cgccpfdig   then
    let l_aux.msg_erro = "cts35m00-Digito do CGC/CPF incorreto!"
    return l_aux.msg_erro
 end if
 ### PSI 202720
 if l_param.ramgrpcod = 5 then ## Saude
    call cta01m15_sel_datksegsau(6, "","",l_param.cgccpfnum, l_param.cpfdig)
         returning m_status, m_msg, m_crtsaunum, m_bnfnum

    if m_status <> 1 then
       let l_aux.msg_erro = "cts35m00-Segurado n�o encontrado-cpfSaude"
    else
       let g_documento.crtsaunum = m_crtsaunum
       let g_documento.bnfnum    = m_bnfnum
       ----------[ busca numero do cartao p/ gravar datrsrvsau ]---------
       open c_cts35m00_026 using g_documento.crtsaunum
       whenever error continue
       fetch c_cts35m00_026 into m_succod,
                               m_ramcod,
                               m_aplnumdig
       whenever error stop
       close c_cts35m00_026
    end if

    return l_aux.msg_erro

 end if

 open c_cts35m00_012 using  l_param.cgccpfnum, l_aux.pestip
 foreach c_cts35m00_012 into l_aux.segnumdig

    if l_param.ramcod = 31 or
       l_param.ramcod = 531 then

      open c_cts35m00_013 using l_aux.segnumdig, l_aux.segnumdig
      foreach c_cts35m00_013 into l_aux.succod, l_aux.aplnumdig

         open c_cts35m00_014 using l_aux.succod, l_aux.aplnumdig
         whenever error continue
         fetch c_cts35m00_014 into l_aux.aplstt, l_aux.viginc, l_aux.vigfnl
         whenever error stop
         close c_cts35m00_014

         if l_aux.aplstt = "C" or       # apolice cancelada
            l_aux.vigfnl < today then  # apolice vencida
            continue foreach
         end if

         #acessar todos os itens da apolice

         open c_cts35m00_015 using l_aux.succod, l_aux.aplnumdig
         foreach c_cts35m00_015 into l_aux.itmnumdig

            # status do item
            open c_cts35m00_016 using l_aux.succod,l_aux.aplnumdig,l_aux.itmnumdig
            whenever error continue
            fetch c_cts35m00_016 into l_aux.itmsttatu
            whenever error stop
            close c_cts35m00_016

            if l_aux.itmsttatu = "A" then
               initialize   l_aux.msg_erro to null
               let g_documento.succod    = l_aux.succod
               let g_documento.ramcod    = l_param.ramcod
               let g_documento.aplnumdig = l_aux.aplnumdig
               let g_documento.itmnumdig = l_aux.itmnumdig
               return l_aux.msg_erro
            end if

         end foreach
         close c_cts35m00_015

      end foreach
      close c_cts35m00_013

   else

       open c_cts35m00_017 using l_aux.segnumdig
       foreach c_cts35m00_017 into l_aux.prporg
                           ,l_aux.prpnumdig
                           ,l_aux.sgrorg
                           ,l_aux.sgrnumdig
                           ,l_aux.dctnumseq
                           ,l_aux.succod
                           ,l_aux.aplnumdig
                           ,l_aux.ramcod

           # verifica se apolice esta ativa
           open c_cts35m00_009 using l_aux.prporg,
                                   l_aux.prpnumdig
           fetch c_cts35m00_009 into l_aux.vigfnl
           close c_cts35m00_009

           if l_aux.vigfnl > today then   # apolice ativa
              initialize l_aux.msg_erro to null
              let g_documento.succod    = l_aux.succod
              let g_documento.ramcod    = l_aux.ramcod
              let g_documento.aplnumdig = l_aux.aplnumdig
              let g_documento.itmnumdig = 0
              return l_aux.msg_erro
           end if

       end foreach
       close c_cts35m00_017

    end if

 end foreach
 close c_cts35m00_012

 if l_aux.aplnumdig is null then
    let l_aux.msg_erro = "cts35m00-Apolice n�o encontrados-cpf"
 end if

 return l_aux.msg_erro

end function
#-------------------------------#
function cts35m00_nome(l_param)
#-------------------------------#
  define l_param record
         nome like datksegsau.segnom
  end record
  define l_aux record
         msg_erro char(40),
         crtstt  like datksegsau.crtstt,
         achou   smallint
  end record


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  l_aux.*  to  null

  initialize l_aux.* to null

  declare c_cts35m00_028 cursor for
     select crtsaunum,bnfnum,crtstt
        from datksegsau
       where segnom = l_param.nome
  let l_aux.achou = 1
  foreach c_cts35m00_028 into g_documento.crtsaunum,
                           g_documento.bnfnum,
                           l_aux.crtstt
     if l_aux.crtstt = "A" then
        let l_aux.achou = 0
        exit foreach
     end if
  end foreach
  if l_aux.achou   =  1 then
     let l_aux.msg_erro = "cts35m00-Cartao nao encontrado-nome"
  else
     let l_aux.msg_erro = null
  end if
  return l_aux.msg_erro
end function

#-----------------------------------------#
function cts35m00_envia_email(lr_parametro)
#-----------------------------------------#

  define lr_parametro record
         assunto      char(100),
         msg          char(10000),
         ambiente     char(08)   ---> Nilo - Trata ambiente - 230408
  end record

  define l_status       smallint,
         l_comando      char(15000),
         l_email        like igbmparam.relpamtxt,
         l_remetentes   char(10000),
         l_remetentescc char(500)

  define l_mail        record
         de            char(500)   # De
        ,para          char(10000)  # Para
        ,cc            char(500)   # cc
        ,cco           char(500)   # cco
        ,assunto       char(500)   # Assunto do e-mail
        ,mensagem      char(32766) # Nome do Anexo
        ,id_remetente  char(20)
        ,tipo          char(4)     #
  end  record
  define l_coderro  smallint
  define msg_erro char(500)
  define l_tamanho  integer
  #----------------------------
  # INICIALIZACAO DAS VARIAVEIS
  #----------------------------
 initialize msg.*          to null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_status  =  null
  let l_comando  =  null
  let l_email  =  null
  let l_remetentes  =  null

  let l_remetentes = null
  let l_comando    = null
  let l_email      = null
  let l_status     = 0

  #--------------------------------------
  # BUSCA OS REMETENTES P/ENVIO DE E-MAIL
  #--------------------------------------
  ---> Nilo / Ruiz - Trata ambiente - 230408
  if lr_parametro.ambiente = 'PRODUCAO' then
     open c_cts35m00_008
     foreach c_cts35m00_008 into l_email
        if l_remetentes is null then
           let l_remetentes = l_email
        else
           let l_remetentes = l_remetentes clipped, ",", l_email
        end if
     end foreach
     close c_cts35m00_008
  else
     open c_cts35m00_008
     foreach c_cts35m00_008 into l_email
        if l_remetentes is null then
           let l_remetentes = l_email
        else
           let l_remetentes = l_remetentes clipped, ",", l_email
        end if

     end foreach
     close c_cts35m00_008
  end if

  if l_remetentes is null or
     l_remetentes = " " then

      let msg.linha1 = "N�O EXISTEM EMAILS CADASTRADOS"
      let msg.linha2 = "EM AMBIENTE DE ",lr_parametro.ambiente clipped
      let msg.linha3 = "PARA INFORMACAO DE FIM DA CARGA CADASTRE"
      let msg.linha4 = "O EMAIL NO MENU CAD_CT24H/E-MAIL_REL"
      call cts08g01 ("A","N",msg.linha1
                            ,msg.linha2
                            ,msg.linha3
                            ,msg.linha4)
          returning msg.confirma
  end if

#PSI-2013-23297 - Inicio
let l_mail.de = "CT24HS"
let l_mail.para =  l_remetentes
let l_mail.cc = ""
let l_mail.cco = ""
let l_mail.assunto = lr_parametro.assunto
let l_mail.mensagem = lr_parametro.msg
let l_mail.id_remetente = "CT24HS"
let l_mail.tipo = "html"
call figrc009_mail_send1 (l_mail.*)
 returning l_coderro,msg_erro
#PSI-2013-23297 - Fim

  return l_status

end function

#-------------------------------------#
report cts35m00_rel_proc1(lr_parametro)
#-------------------------------------#



  define lr_parametro       record
         seqreg             like datmcntsrv.seqreg,
         seqregcnt          like datmcntsrv.seqregcnt,
         c24astcod          like datmcntsrv.c24astcod,
         atdsrvorg          like datmcntsrv.atdsrvorg,
         atdsrvnum          like datmcntsrv.atdsrvnum,
         atdsrvano          like datmcntsrv.atdsrvano,
         dstsrvnum          like datmcntsrv.dstsrvnum,
         dstsrvano          like datmcntsrv.dstsrvano,
         ciaempcod          like datmcntsrv.ciaempcod,
         atldat             like datmcntsrv.atldat,
         atlhor             like datmcntsrv.atlhor,
         coderro            integer,
         deserro            char(300)
  end record

  output

		    left   margin 000
		    top    margin 000
		    bottom margin 000

		 format
		    first page header
		       print  "<html><table border=1>"
		       			 ,"<tr>"
		       			 ,"<th colspan = 11 align='center' bgcolor='gray'> RELATORIO DE ERROS DA CONTINGENCIA - PROCESSO 1 </th></tr>"
		             ,"<tr>"
		             ,"<th align='center' bgcolor='gray'>SEQUENCIA DO REG. NO SISTEMA</th>"
		             ,"<th align='center' bgcolor='gray'>SEQUENCIA DO REG. NA CTG.</th>"
		             ,"<th align='center' bgcolor='gray'>CODIGO DO ASSUNTO</th>"
                 ,"<th align='center' bgcolor='gray'>ORIGEM DO SERVICO</th>"
                 ,"<th align='center' bgcolor='gray'>SERVICO NO IFX.</th>"
                 ,"<th align='center' bgcolor='gray'>SERVICO NA CTG.</th>"
                 ,"<th align='center' bgcolor='gray'>EMPRESA</th>"
                 ,"<th align='center' bgcolor='gray'>DATA DE ATUALIZACAO</th>"
                 ,"<th align='center' bgcolor='gray'>HORA DE ATUALIZACAO</th>"
                 ,"<th align='center' bgcolor='gray'>SQLCA.SQLCODE</th>"
                 ,"<th align='center' bgcolor='gray'>DESCRICAO DO ERRO</th>"
                 ,"</tr>"
		    on every row
		       print  "<tr>"
		       				,"<td width=80 align='center' >",lr_parametro.seqreg, "</td>"
		              ,"<td width=85 align='center' >",lr_parametro.seqregcnt, "</td>"
		              ,"<td width=65 align='center' >",lr_parametro.c24astcod, "</td>"
		              ,"<td width=65 align='center' >",lr_parametro.atdsrvorg, "</td>"
		              ,"<td width=100 align='center'>",lr_parametro.atdsrvnum using "<<<<<<<<<&", "-"
                                                  ,lr_parametro.atdsrvano using "&&", "</td>"
                  ,"<td width=100 align='center'>",lr_parametro.dstsrvnum using "<<<<<<<<<&", "-"
                                                  ,lr_parametro.dstsrvano using "&&", "</td>"
                  ,"<td width=80 align='center' >",lr_parametro.ciaempcod, "</td>"
                  ,"<td width=95 align='center' >",lr_parametro.atldat, "</td>"
                  ,"<td width=95 align='center' >",lr_parametro.atlhor, "</td>"
                  ,"<td width=110 align='center'>",lr_parametro.coderro, "</td>"
		              ,"<td width=150 align='center'>",lr_parametro.deserro, "</td></tr>"

end report

#-------------------------------------#
report cts35m00_rel_proc2(lr_parametro)
#-------------------------------------#

  define lr_parametro       record
         seqregcnt          like datmcntsttvcl.seqregcnt,
         atdsrvnum          like datmcntsttvcl.atdsrvnum,
         atdsrvano          like datmcntsttvcl.atdsrvano,
         coderro            integer,
         deserro            char(300)
  end record

  output

		    left   margin 000
		    top    margin 000
		    bottom margin 000

		 format
		    first page header
		       print  "<html><table border=1>"
		       			 ,"<tr>"
		       			 ,"<td colspan = 4 align='center'> RELATORIO DE ERROS DA CONTINGENCIA - PROCESSO 2 </td></tr>"
		             ,"<tr>"
		             ,"<th align='center' bgcolor='gray'>SEQUENCIA DO REG.</th>"
		             ,"<th align='center' bgcolor='gray'>SERVICO</th>"
		             ,"<th align='center' bgcolor='gray'>SQLCA.SQLCODE</th>"
                 ,"<th align='center' bgcolor='gray'>DESCRICAO DO ERRO</th>"
                 ,"</tr>"
		    on every row
		       print  "<tr>"
		       				,"<td width=80 align='center'>",lr_parametro.seqregcnt , "</td>"
		              ,"<td width=150 align='center'>",lr_parametro.atdsrvnum using "<<<<<<<<<&", "-"
                                                  ,lr_parametro.atdsrvano using "&&", "</td>"
		              ,"<td width=95 align='center'>",lr_parametro.coderro clipped, "</td>"
		              ,"<td width=90 align='center'>",lr_parametro.deserro, "</td></tr>"

end report

#-------------------------------------#
report cts35m00_rel_proc3(lr_parametro)
#-------------------------------------#

  define lr_parametro       record
         seqregcnt          like datmcntmsgctr.seqregcnt,
         novmsgflg          like datmcntmsgctr.novmsgflg,
         mdtmsgnum          like datmcntmsgctr.mdtmsgnum,
         atdsrvnum          like datmcntmsgctr.atdsrvnum,
         atdsrvano          like datmcntmsgctr.atdsrvano,
         coderro            integer,
         deserro            char(300)
  end record

   output
		    left   margin 000
		    top    margin 000
		    bottom margin 000

		 format
		    first page header
		       print  "<html><table border=1>"
		       			 ,"<tr>"
		       			 ,"<td colspan = 6 align='center'> RELATORIO DE ERROS DA CONTINGENCIA - PROCESSO 3 </td></tr>"
		             ,"<tr>"
		             ,"<th align='center' bgcolor='gray'>SEQUENCIA DO REG. NO SISTEMA</th>"
		             ,"<th align='center' bgcolor='gray'>MENSAGEM NOVA</th>"
		             ,"<th align='center' bgcolor='gray'>NUMERO DA MENSAGEM</th>"
                 ,"<th align='center' bgcolor='gray'>SERVICO</th>"
                 ,"<th align='center' bgcolor='gray'>SQLCA.SQLCODE</th>"
                 ,"<th align='center' bgcolor='gray'>DESCRICAO DO ERRO</th>"
                 ,"</tr>"
		    on every row
		       print  "<tr>"
		       				,"<td width=80 align='center'>",lr_parametro.seqregcnt , "</td>"
		              ,"<td width=85 align='center'>",lr_parametro.novmsgflg, "</td>"
		              ,"<td width=65 align='center'>",lr_parametro.mdtmsgnum, "</td>"
		              ,"<td width=150 align='center'>",lr_parametro.atdsrvnum using "<<<<<<<<<&", "-"
                                                  ,lr_parametro.atdsrvano using "&&", "</td>"
		              ,"<td width=95 align='center'>",lr_parametro.coderro clipped, "</td>"
		              ,"<td width=90 align='center'>",lr_parametro.deserro, "</td></tr>"

end report
#-------------------------------------#
report cts35m00_rel_proc4(lr_parametro)
#-------------------------------------#

  define lr_parametro       record
         seqregcnt          like datmcntmsgctr.seqregcnt,
         novmsgflg          like datmcntmsgctr.novmsgflg,
         mdtmsgnum          like datmcntmsgctr.mdtmsgnum,
         atdsrvnum          like datmcntmsgctr.atdsrvnum,
         atdsrvano          like datmcntmsgctr.atdsrvano,
         coderro            integer,
         deserro            char(300)
  end record

   output
		    left   margin 000
		    top    margin 000
		    bottom margin 000

		 format
		    first page header
		       print  "<html><table border=1>"
		       			 ,"<tr>"
		       			 ,"<td colspan = 6 align='center'> RELATORIO DE ERROS DA CONTINGENCIA - PROCESSO 4 </td></tr>"
		             ,"<tr>"
		             ,"<th align='center' bgcolor='gray'>SEQUENCIA DO REG. NO SISTEMA</th>"
		             ,"<th align='center' bgcolor='gray'>MENSAGEM NOVA</th>"
		             ,"<th align='center' bgcolor='gray'>NUMERO DA MENSAGEM</th>"
                 ,"<th align='center' bgcolor='gray'>SERVICO</th>"
                 ,"<th align='center' bgcolor='gray'>SQLCA.SQLCODE</th>"
                 ,"<th align='center' bgcolor='gray'>DESCRICAO DO ERRO</th>"
                 ,"</tr>"
		    on every row
		       print  "<tr>"
		       				,"<td width=80 align='center'>",lr_parametro.seqregcnt , "</td>"
		              ,"<td width=85 align='center'>",lr_parametro.novmsgflg, "</td>"
		              ,"<td width=65 align='center'>",lr_parametro.mdtmsgnum, "</td>"
		              ,"<td width=150 align='center'>",lr_parametro.atdsrvnum using "<<<<<<<<<&", "-"
                                                  ,lr_parametro.atdsrvano using "&&", "</td>"
		              ,"<td width=95 align='center'>",lr_parametro.coderro clipped, "</td>"
		              ,"<td width=90 align='center'>",lr_parametro.deserro, "</td></tr>"

end report

#===================================#
function cts35m00_email_rel(lr_param)
#===================================#

 define lr_param record
        modulo   char(50),
        assunto  char(300),
        anexo    char(300)
 end record

 define l_comando char(1000)
 define l_destino char(800)
 define l_ambiente char(10)

 define  l_mail             record
   de                 char(500)   # De
  ,para               char(5000)  # Para
  ,cc                 char(500)   # cc
  ,cco                char(500)   # cco
  ,assunto            char(500)   # Assunto do e-mail
  ,mensagem           char(32766) # Nome do Anexo
  ,id_remetente       char(20)
  ,tipo               char(4)     #
 end  record

 define l_coderro  smallint
 define msg_erro char(500)
#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_comando  =  null
        let     l_destino  =  null
        let     l_ambiente =  null

 let l_destino = null
 let l_comando = null
 let l_ambiente =  null
 initialize msg.* to null
  if g_outFigrc012.Is_Teste then
     open c_cts35m00_033
      fetch c_cts35m00_033 into l_destino
     close c_cts35m00_033
     if l_destino is null or
        l_destino = " " then
       let msg.linha1 = "N�O EXISTEM EMAILS CADASTRADOS"
       let msg.linha2 = "EM AMBIENTE DE TESTE PARA ENVIO DE"
       let msg.linha3 = "RELATORIO. CADASTRE O EMAIL NO MENU"
       let msg.linha4 = "CAD_CT24H/DOMINIO: cts35m00_email_rel"
       call cts08g01 ("A","N",msg.linha1
                             ,msg.linha2
                             ,msg.linha3
                             ,msg.linha4)
           returning msg.confirma
     end if
  else
    let l_destino = "info.sistemasmadeira@portoseguro.com.br, info.sistemasniagara@portoseguro.com.br"
  end if

 #PSI-2013-23297 - Inicio
 let l_mail.de = "CT24HS"
 let l_mail.para = l_destino
 let l_mail.cc = ""
 let l_mail.cco = ""
 let l_mail.assunto = lr_param.assunto
 let l_mail.mensagem = lr_param.modulo
 let l_mail.id_remetente = "CT24HS"
 let l_mail.tipo = "html"

 call figrc009_attach_file(lr_param.anexo)
 call figrc009_mail_send1 (l_mail.*)
   returning l_coderro,msg_erro
 #PSI-2013-23297 - Fim

end function


#------------------------------------------#
function cts35m00_insere_etapa(lr_parametro)
#------------------------------------------#

  define lr_parametro record
         atdsrvnum    like datmsrvacp.atdsrvnum,
         atdsrvano    like datmsrvacp.atdsrvano,
         atdetpcod    like datmsrvacp.atdetpcod,
         atdetpdat    like datmsrvacp.atdetpdat,
         atdetphor    like datmsrvacp.atdetphor,
         empcod       like datmsrvacp.empcod,
         funmat       like datmsrvacp.funmat,
         pstcoddig    like datmsrvacp.pstcoddig,
         srrcoddig    like datmsrvacp.srrcoddig,
         socvclcod    like datmsrvacp.socvclcod,
         c24nomctt    like datmsrvacp.c24nomctt
  end record

  define l_atdsrvseq  like datmsrvacp.atdsrvseq,
         l_status     integer, # 0 -> OK    <> 0 -> ERRO
         l_sttetp     integer  # 0 -> OK    <> 0 -> ERRO


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	let	l_atdsrvseq  =  null
	let	l_status     =  null
	let     l_sttetp     =  null

  let l_status    = 0
  let l_sttetp    = 0
  let l_atdsrvseq = null

  # -> BUSCA A ULTIMA SEQUENCIA DO SERVICO
  open c_cts35m00_025 using lr_parametro.atdsrvnum, lr_parametro.atdsrvano
  fetch c_cts35m00_025 into l_atdsrvseq
  close c_cts35m00_025

  if l_atdsrvseq is null then
     let l_atdsrvseq = 0
  end if

  let l_atdsrvseq = (l_atdsrvseq + 1)

  # -> SE A DATA FOR NULA, ASSUME A DATA ATUAL
  if lr_parametro.atdetpdat is null then
     let lr_parametro.atdetpdat = today
  end if

  # -> SE A HORA FOR NULA, ASSUME A HORA ATUAL
  if lr_parametro.atdetphor is null then
     let lr_parametro.atdetphor = current
  end if

  # -> SE A MATRICULA FOR NULA, ASSUME A MATRICULA 999999(SISTEMA)
  if lr_parametro.funmat is null then
     let lr_parametro.funmat = 999999
  end if

  # -> INSERE NA datmsrvacp
  whenever error continue
  execute p_cts35m00_043 using lr_parametro.atdsrvnum,
                               lr_parametro.atdsrvano,
                               l_atdsrvseq,
                               lr_parametro.atdetpcod,
                               lr_parametro.atdetpdat,
                               lr_parametro.atdetphor,
                               lr_parametro.empcod,
                               lr_parametro.funmat,
                               lr_parametro.pstcoddig,
                               lr_parametro.srrcoddig,
                               lr_parametro.socvclcod,
                               lr_parametro.c24nomctt
  whenever error stop

  let l_status = sqlca.sqlcode

  call cts00g07_apos_grvetapa(lr_parametro.atdsrvnum,
                              lr_parametro.atdsrvano,
                              l_atdsrvseq,1)

  call cts10g04_alt_etapa(lr_parametro.atdsrvnum,
                          lr_parametro.atdsrvano,
                          lr_parametro.atdetpcod)
       returning l_sttetp

  return l_status

end function

#--------------------------------------------------#
function cts35m00_verifica_contador()
#--------------------------------------------------#
define a_constante array[5] of record
    grlchv like datkgeral.grlchv ,
    cont   integer
end record
define lr_aux record
  data date                   ,
  hora datetime hour to second
end record
define arr_aux integer
for  arr_aux  =  1  to  5
   initialize  a_constante[arr_aux].* to  null
end  for
initialize lr_aux.* to null
let a_constante[1].grlchv = "cts35totreg"
let a_constante[2].grlchv = "cts35totsrvifx"
let a_constante[3].grlchv = "cts35totsrvctg"
let a_constante[4].grlchv = "cts35achei"
let a_constante[5].grlchv = "cts35nachei"
let lr_aux.data = today
let lr_aux.hora = current hour to second
  for arr_aux  =  1  to 5
    open ccts35m00056 using a_constante[arr_aux].grlchv
    fetch  ccts35m00056 into a_constante[arr_aux].cont
    if sqlca.sqlcode = notfound then
      let a_constante[arr_aux].cont = 0
      # Insere a chave , nao ha Tratamento de Erro
      execute pcts35m00057 using a_constante[arr_aux].grlchv ,
                                 a_constante[arr_aux].cont   ,
                                 lr_aux.data                 ,
                                 lr_aux.hora                 ,
                                 g_issk.empcod               ,
                                 g_issk.funmat
    end if
    close ccts35m00056
  end for
  return  a_constante[1].cont,
          a_constante[2].cont,
          a_constante[3].cont,
          a_constante[4].cont,
          a_constante[5].cont
end function
#--------------------------------------------------#
function cts35m00_atualiza_contador(lr_param)
#--------------------------------------------------#
define lr_param record
    reg  char(9) ,
    cont integer
end record
define lr_aux record
    grlchv char(15)
end record
initialize lr_aux.* to null
 let lr_aux.grlchv = "cts35", lr_param.reg clipped
    # Atualiza o Contador, nao ha Tratamento de Erro
    whenever error continue
    execute pcts35m00058 using lr_param.cont ,
                               lr_aux.grlchv
    whenever error stop
end function
#--------------------------------------------------#
function cts35m00_deleta_contador()
#--------------------------------------------------#
define a_constante array[6] of record
    grlchv like datkgeral.grlchv
end record
define arr_aux integer
for  arr_aux  =  1  to  6
   initialize  a_constante[arr_aux].* to  null
end  for
let a_constante[1].grlchv = "cts35totreg"
let a_constante[2].grlchv = "cts35totsrvifx"
let a_constante[3].grlchv = "cts35totsrvctg"
let a_constante[4].grlchv = "cts35achei"
let a_constante[5].grlchv = "cts35nachei"
let a_constante[6].grlchv = "cts35seqreg"
  for arr_aux  =  1  to 6
     # Remove Chave, nao ha Tratamento de Erro
     execute pcts35m00059 using a_constante[arr_aux].grlchv
  end for
end function
#--------------------------------------------------#
function cts35m00_grava_sequencia(lr_param)
#--------------------------------------------------#
define lr_param record
   seqreg like datmcntsrv.seqreg
end record
define lr_aux record
  data   date                   ,
  hora   datetime year to second,
  grlchv like datkgeral.grlchv  ,
  seqreg like datmcntsrv.seqreg
end record
initialize lr_aux.* to null
let lr_aux.grlchv = "cts35seqreg"
let lr_aux.data   = today
let lr_aux.hora   = current hour to second
    open ccts35m00056 using lr_aux.grlchv
    fetch  ccts35m00056 into lr_aux.seqreg
    if sqlca.sqlcode = notfound then
      # Insere a chave , nao ha Tratamento de Erro
      execute pcts35m00057 using lr_aux.grlchv               ,
                                 lr_param.seqreg             ,
                                 lr_aux.data                 ,
                                 lr_aux.hora                 ,
                                 g_issk.empcod               ,
                                 g_issk.funmat
    end if
    close ccts35m00056
    return  lr_aux.seqreg
end function

#======================================#
 function cts35m00_verifica_versao()
#======================================#

define l_retorno smallint,
       l_chave   char(30),
       l_versao   smallint


let l_retorno = 0
let l_chave  = "versao_carga"

declare c_cts35m00_030 cursor with hold for
select cpodes from datkdominio
where cponom = l_chave


open c_cts35m00_030 using l_chave
whenever error continue
fetch c_cts35m00_030 into l_versao
whenever error stop


let l_retorno = l_versao

return l_retorno

end function

#------------------------------------------#
 function cts35m00_cgccpf_portofaz(lr_param)
#------------------------------------------#

     define lr_param record
            lignum    like datrligcgccpf.lignum,
            cgccpfnum like datrligcgccpf.cgccpfnum,
            cgcord    like datrligcgccpf.cgcord,
            cgccpfdig like datrligcgccpf.cgccpfdig
     end record

     define l_aux        record
            msg_erro     char(40)
           ,pestip       char(01)
           ,cgccpfdig    like datrligcgccpf.cgccpfdig
     end record


     sleep 2

     if lr_param.cgcord > 0 then
       let l_aux.pestip = "J"
     else
       let l_aux.pestip = "F"
     end if

     if l_aux.pestip =  "J"    then
        call F_FUNDIGIT_DIGITOCGC(lr_param.cgccpfnum
                                 ,lr_param.cgcord)
             returning l_aux.cgccpfdig
     else
        call F_FUNDIGIT_DIGITOCPF(lr_param.cgccpfnum)
             returning l_aux.cgccpfdig
     end if

     if l_aux.cgccpfdig is null or
        lr_param.cgccpfdig <> l_aux.cgccpfdig   then
        let l_aux.msg_erro = "cts35m00-Digito do CGC/CPF - PORTO FAZ incorreto!"
        return l_aux.msg_erro
     end if

     #display "l_aux.msg_erro = ", l_aux.msg_erro

     whenever error continue
     execute p_cts35m00_066 using lr_param.lignum,
                                  lr_param.cgccpfnum,
                                  lr_param.cgcord,
                                  lr_param.cgccpfdig
     whenever error stop
      let l_aux.msg_erro = "OK!"
      return l_aux.msg_erro
 end function