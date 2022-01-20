#------------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: BDBSA600                                                   #
# ANALISTA RESP..: MARCOS FEDERICCE                                           #
# PSI/OSF........: 223565                                                     #
#                  CARGA AUTOMATICA DA CONTINGENCIA.                          #
# ........................................................................... #
# DESENVOLVIMENTO: SERGIO BURINI                                              #
# LIBERACAO......: 14/05/2008                                                 #
# ........................................................................... #
#                                                                             #
#                     * * * Alteracoes * * *                                  #
#                                                                             #
# Data        Autor Fabrica    Origem     Alteracao                           #
# ----------  --------------   --------- -------------------------------------#
# 24/11/2008 Priscila Staingel PSI230650  Nao utilizar a 1 posicao do assunto #
#                                         como sendo o agrupamento, buscar cod#
#                                         agrupamento.                        #
#-----------------------------------------------------------------------------#
# 18/03/2010 Carla Rampazzo    PSI219444  Tratar inclusao em datmsrvre dos    #
#                                         campos (lclnumseq / rmerscseq)      #
#-----------------------------------------------------------------------------#

globals '/homedsa/projetos/geral/globals/glct.4gl'
globals '/homedsa/projetos/geral/globals/figrc012.4gl'

database porto

 define m_status      smallint,
        m_msg         char(50),
        m_crtsaunum   like datrligsau.crtnum,
        m_bnfnum      like datrligsau.bnfnum,
        m_succod      like datksegsau.succod,
        m_ramcod      like datksegsau.ramcod,
        m_aplnumdig   like datksegsau.aplnumdig,
        m_prcstt      like dpamcrtpcs.prcstt,
        m_curr        datetime year to second,
        m_tmpexp      datetime year to second

 main
     let g_issk.funmat = '999999'
     let g_issk.usrtip = 'F'

     call startlog("bdbsa600.log")

     call fun_dba_abre_banco("CT24HS")
     call bdbsa600_prepare()

     let  m_tmpexp = current

     while true

         call ctx28g00("bdbsa600", fgl_getenv("SERVIDOR"), m_tmpexp)
              returning m_tmpexp, m_prcstt

         if  m_prcstt = 'A' then
             call bdbsa600()
         end if

         sleep 60
     end while
 end main

#---------------------------#
 function bdbsa600_prepare()
#---------------------------#

     define l_sql char(5000)

     #INTERFACE PARA BUSCA DOS SERVICOS
     let l_sql = "select seqreg, ",
                       " seqregcnt, ",
                       " atdsrvorg, ",
                       " atdsrvnum, ",
                       " atdsrvano, ",
                       " srvtipabvdes, ",
                       " atdnom, ",
                       " funmat, ",
                       " asitipabvdes, ",
                       " c24solnom, ",
                       " vcldes, ",
                       " vclanomdl, ",
                       " vclcor, ",
                       " vcllicnum, ",
                       " vclcamtip, ",
                       " vclcrgflg, ",
                       " vclcrgpso, ",
                       " atddfttxt, ",
                       " segnom, ",
                       " aplnumdig, ",
                       " cpfnum, ",
                       " ocrufdcod, ",
                       " ocrcidnom, ",
                       " ocrbrrnom, ",
                       " ocrlgdnom, ",
                       " ocrendcmp, ",
                       " ocrlclcttnom, ",
                       " ocrlcltelnum, ",
                       " ocrlclrefptotxt, ",
                       " dsttipflg, ",
                       " dstufdcod, ",
                       " dstcidnom, ",
                       " dstbrrnom, ",
                       " dstlgdnom, ",
                       " rmcacpflg, ",
                       " obstxt, ",
                       " srrcoddig, ",
                       " srrabvnom, ",
                       " atdvclsgl, ",
                       " atdprscod, ",
                       " nomgrr, ",
                       " atddat, ",
                       " atdhor, ",
                       " acndat, ",
                       " acnhor, ",
                       " acnprv, ",
                       " c24openom, ",
                       " c24opemat, ",
                       " pasnom1, ",
                       " pasida1, ",
                       " pasnom2, ",
                       " pasida2, ",
                       " pasnom3, ",
                       " pasida3, ",
                       " pasnom4, ",
                       " pasida4, ",
                       " pasnom5, ",
                       " pasida5, ",
                       " atldat, ",
                       " atlhor, ",
                       " atlmat, ",
                       " atlnom, ",
                       " cnlflg, ",
                       " cnldat, ",
                       " cnlhor, ",
                       " cnlmat, ",
                       " cnlnom, ",
                       " socntzcod, ",
                       " c24astcod, ",
                       " atdorgsrvnum, ",
                       " atdorgsrvano, ",
                       " srvtip, ",
                       " acnifmflg, ",
                       " dstsrvnum, ",
                       " dstsrvano, ",
                       " prcflg, ",
                       " ramcod, ",
                       " succod, ",
                       " itmnumdig, ",
                       " ocrlcldddcod, ",
                       " cpfdig, ",
                       " cgcord, ",
                       " ocrendzoncod, ",
                       " dstendzoncod, ",
                       " sindat, ",
                       " sinhor, ",
                       " bocnum, ",
                       " boclcldes, ",
                       " sinavstip, ",
                       " vclchscod, ",
                       " obscmptxt, ",
                       " crtsaunum, ",
                       " ciaempcod  ",
                 "  from datmcntsrv  ",
                "  where prcflg = 'N' "

     prepare pbdbsa600001 from l_sql
     declare cbdbsa600001 cursor with hold for pbdbsa600001

     # TABELA DE VEICULO
     let l_sql = " select socvclcod from datkveiculo "
               , "  where atdvclsgl = ? "

     prepare pbdbsa600002 from l_sql
     declare cbdbsa600002 cursor for pbdbsa600002

     # VERIFICACAO DO SERVICO
     let l_sql = " select 1 ",
                   " from datmservico ",
                  " where atdsrvnum = ? ",
                    " and atdsrvano = ? "

     prepare pbdbsa600041 from l_sql
     declare cbdbsa600041 cursor for pbdbsa600041

     # BUSCA APOLICE DO CARTAO SAUDE
     let l_sql = " select succod,       ",
                 "        ramcod,       ",
                 "        aplnumdig     ",
                 "   from datksegsau    ",
                 "  where crtsaunum = ? "

     prepare pbdbsa600053 from l_sql
     declare cbdbsa600053 cursor for pbdbsa600053

     # BUSCA DO DOMINIO
     let l_sql = " select cpocod ",
                   " from iddkdominio ",
                  " where cponom = 'vclcorcod' ",
                    " and cpodes = ? "

     prepare pbdbsa600025 from l_sql
     declare cbdbsa600025 cursor with hold for pbdbsa600025

     # QUANTIDADE DE PASSAGERIOS
     let l_sql = " select max(passeq) ",
                   " from datmpassageiro ",
                  " where atdsrvnum = ? ",
                    " and atdsrvano = ? "

     prepare pbdbsa600030 from l_sql
     declare cbdbsa600030 cursor for pbdbsa600030

     # TABELA INTERFACE DE VEICULO
     let l_sql = "select seqreg "
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

     prepare pbdbsa600010 from l_sql
     declare cbdbsa600010 cursor with hold for pbdbsa600010

     # BUSCA ULTIMA SEQUENCIA DO SERVICO
     let l_sql = " select dstsrvnum, ",
                        " dstsrvano ",
                   " from datmcntsrv ",
                  " where seqreg = (select max(seqreg) ",
                                    " from datmcntsrv ",
                                   " where seqregcnt = ?) "

     prepare pbdbsa600009 from l_sql
     declare cbdbsa600009 cursor with hold for pbdbsa600009

     # INTERFACE COM A TABELA DE MENSAGENS
     let l_sql = " select mdtmsgnum, ",
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

     prepare pbdbsa600012 from l_sql
     declare cbdbsa600012 cursor with hold for pbdbsa600012

     # INTERFACE COM A TABELA DE LOGS
     let l_sql = " select datmcntlogctr.mdtmsgnum, ",
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

     prepare pbdbsa600016 from l_sql
     declare cbdbsa600016 cursor with hold for pbdbsa600016

     # BUSCA A MENSAGEM DO MDT PARA O SERVICO
     let l_sql = " select mdtmsgnum  ",
                 "   from datmmdtsrv ",
                 "  where mdtmsgnum = (select max(mdtmsgnum) ",
                                     "   from datmmdtsrv     ",
                                     "  where atdsrvnum = ?  ",
                                     "    and atdsrvano = ?) "
     prepare pbdbsa600044 from l_sql
     declare cbdbsa600044 cursor with hold for pbdbsa600044

     # MAXIMA SEQUENCIA DO LOG PARA O NUMERO DO MDT
     let l_sql = " select max(mdtlogseq) ",
                   " from datmmdtlog ",
                  " where mdtmsgnum = ? "

     prepare pbdbsa600017 from l_sql
     declare cbdbsa600017 cursor with hold for pbdbsa600017

     # NUEMRO DO SEGURADO
     let l_sql =  " select segnumdig ",
                    " from gsakseg ",
                   " where cgccpfnum = ? ",
                     " and pestip = ? "

     prepare pbdbsa600034 from l_sql
     declare cbdbsa600034 cursor for pbdbsa600034

     # VERIFICA A VIGENCIA DO SEGURADO
     let l_sql = " select unique succod, ",
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

     prepare pbdbsa600035 from l_sql
     declare cbdbsa600035 cursor for pbdbsa600035

     # BUSCA STATUS DA APOLICE
     let l_sql = " select aplstt, ",
                        " viginc, ",
                        " vigfnl ",
                   " from abamapol ",
                  " where succod = ? ",
                    " and aplnumdig = ? "

     prepare pbdbsa600036 from l_sql
     declare cbdbsa600036 cursor for pbdbsa600036

     #BUSCA ITEM DA APOLICE
     let l_sql = " select itmnumdig ",
                   " from abbmdoc ",
                  " where succod = ? ",
                    " and aplnumdig = ? "

     prepare pbdbsa600037 from l_sql
     declare cbdbsa600037 cursor for pbdbsa600037

     # BUSCA STATUS DO ITEM
     let l_sql = " select itmsttatu ",
                   " from abbmitem ",
                  " where succod = ? ",
                    " and aplnumdig = ? ",
                    " and itmnumdig = ? "

     prepare pbdbsa600038 from l_sql
     declare cbdbsa600038 cursor for pbdbsa600038

     # DADOS DA APOLICE DE SEGURO RE
     let l_sql = " select rsdmdocto.prporg ",
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

     prepare pbdbsa600039 from l_sql
     declare cbdbsa600039 cursor for pbdbsa600039

     # VIGENCIA FINAL DA PORPOSTA
     let l_sql = " select vigfnl ",
                   " from rsdmdocto ",
                  " where prporg = ? ",
                    " and prpnumdig = ? "

     prepare pbdbsa600022 from l_sql
     declare cbdbsa600022 cursor for pbdbsa600022

     # MAXIMA ETAPA DO ACIONAMENTO
     let l_sql = " select max(atdsrvseq) ",
                   " from datmsrvacp ",
                  " where atdsrvnum = ? ",
                    " and atdsrvano = ? "

     prepare pbdbsa600049 from l_sql
     declare cbdbsa600049 cursor with hold for pbdbsa600049

     # INSERE ETAPA
     let l_sql = " insert into datmsrvacp (atdsrvnum, ",
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

     prepare pbdbsa600048 from l_sql

     # BUSCA DADOS DA APOLICE
     let l_sql = " select abbmveic.succod ",
                       " ,abbmveic.aplnumdig ",
                       " ,abbmveic.itmnumdig ",
                       " ,max(abbmveic.dctnumseq) ",
                   " from abbmveic ",
                  " where abbmveic.vcllicnum = ? ",
                  " group by succod, aplnumdig, itmnumdig "

     prepare pbdbsa600040 from l_sql
     declare cbdbsa600040 cursor for pbdbsa600040

     # ATUALIZA FLAG DE CARGA DE CONTINGENCIA
     let l_sql = " update datkgeral set ",
                 "      (grlinf,   ",
                 "       atldat,   ",
                 "       atlhor) = ",
                 "       ('PROCESSADA',today,current hour to second) ",
                 " where grlchv = 'PSOCNTCARGA'   ",
                 "   and grlinf = 'NAO PROCESSADA' "
     prepare pbdbsa600054 from l_sql

     # ATUALIZA O FLAG DO SERVIÇO PROCESSADO
     let l_sql = " update datmcntsrv ",
                   " set (dstsrvnum, dstsrvano, prcflg)= (?,?,'S') ",
                  " where seqreg = ? "

     prepare pbdbsa600033 from l_sql

     # ATUALIZA O FLAG DO SERVIÇO PROCESSADO ATRAVES DA SEQUENCIA
     let l_sql = " update datmcntsrv ",
                    " set prcflg = 'S' ",
                  " where seqreg = ? "

     prepare pbdbsa600024 from l_sql

     # INCLUI NA TABELA DE RELACIONAMENTO DE SERVIÇO x
     let l_sql = " insert into datrservapol ",
                            " (atdsrvnum, ",
                             " atdsrvano, ",
                             " succod, ",
                             " ramcod, ",
                             " aplnumdig, ",
                             " itmnumdig, ",
                             " edsnumref) ",
                      " values(?,?,?,?,?,?,?) "

     prepare pbdbsa600026 from l_sql

     # INCLUI COMPLEMENTO DO SERVIÇO
     let l_sql = " insert into datmservicocmp ",
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

     prepare pbdbsa600027 from l_sql

     # INLCUI LOCALIDADE DO SERVIÇO
     let l_sql = " insert into datmlcl(atdsrvnum, ",
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

     prepare pbdbsa600032 from l_sql

     # SELECIONA DADOS PARA ENVIAR E-MAIL DE FINALIZAÇÃO DA CARGA DA CONTINGENCIA.
     let l_sql = "select psccntcod, ",
                       " fnldat, ",
                       " inidat ",
                  " from datkcnthst ",
                 " where maienvflg = 'N' "

     prepare pbdbsa600042 from l_sql
     declare cbdbsa600042 cursor for pbdbsa600042

     # ATUALIZA TABELA DE LOG
     let l_sql = " update datmcntlogctr set ",
                        " prcflg = 'S' ",
                   " where mdtmsgnum = ? "

     prepare pbdbsa600043 from l_sql

     # ATUALIZA TABELA DE CONTROLE DE ENVIO DE E-MAIL.
     let l_sql = " update datkcnthst set ",
                        " maienvflg = 'S' ",
                   " where psccntcod = ? "

     prepare pbdbsa600045 from l_sql

     # INCLUI NA TABELA DE SERVIÇOS DE RE
     let l_sql = " insert into datmsrvre ",
                            " (atdsrvnum, ",
                             " atdsrvano, ",
                             " lclrsccod, ",
                             " orrdat, ",
                             " orrhor, ",
                             " socntzcod, ",
                             " atdsrvretflg, ",
                             " atdorgsrvnum, ",
                             " atdorgsrvano, ",
                             " srvretmtvcod, ",
                             " lclnumseq, ",
                             " rmerscseq) ",
                  " values(?,?,null,today,'00:00', ",
                          " ?,'N',?,?,null,null,null) "

     prepare pbdbsa600028 from l_sql

     # INCLUI TABELA DE ASSISTENCIA AO PASSAGEIRO
     let l_sql = " insert into datmassistpassag ",
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

     prepare pbdbsa600029 from l_sql

     # ATUALIZA TABELA DE SERVIÇOS
     let l_sql = "update datmservico   ",
                   " set atdprscod = ? ",
                      " ,socvclcod = ? ",
                      " ,srrcoddig = ? ",
                      " ,c24nomctt = ? ",
                      " ,atdfnlhor = ? ",
                      " ,c24opemat = ? ",
                      " ,cnldat    = ? ",
                      " ,atdcstvlr = '' ",
                      " ,atdprvdat = '' ",
                      " ,atdfnlflg = 'S'",
                      " where atdsrvnum = ?  ",
                      "   and atdsrvano = ?  "

     prepare pbdbsa600003 from l_sql

     # ATUALIZA TABELA DE SERVIÇOS
     let l_sql = " update datmservico ",
                    " set atdfnlflg = 'S' ",
                  " where atdsrvnum = ? ",
                    " and atdsrvano = ? "

     prepare pbdbsa600023 from l_sql

     # ATUALIZA TABELA DE SERVIÇOS SAUDE
     let l_sql = " insert into datrsrvsau ",
                            " (atdsrvnum, ",
                             " atdsrvano, ",
                             " succod, ",
                             " ramcod, ",
                             " aplnumdig, ",
                             " crtnum, ",
                             " bnfnum) ",
                      " values(?,?,?,?,?,?,?) "

     prepare pbdbsa600052 from l_sql

     # INCLUI TABELA DE PASSAGEIROS
     let l_sql = " insert into datmpassageiro ",
                            " (atdsrvnum, ",
                             " atdsrvano, ",
                             " passeq, ",
                             " pasnom, ",
                             " pasidd) ",
                      " values(?,?,?,?,?) "

     prepare pbdbsa600031 from l_sql

     # ATUALIZA TABELA DE POSIÇÃO DE FROTA
     let l_sql = " update datmfrtpos set ",
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

     prepare pbdbsa600011 from l_sql

     # DELETA DA TABELA DE SE CONTROLE DE VEICULOS
     let l_sql = " delete from datmcntsttvcl "

     prepare pbdbsa600050 from l_sql

     # INCLUI NA TABELA DE MENSAGENS DE MDT
     let l_sql = " insert into datmmdtmsg ",
                            " (mdtmsgnum, ",
                             " mdtmsgorgcod, ",
                             " mdtcod, ",
                             " mdtmsgstt, ",
                             " mdtmsgavstip) ",
                      " values(0,?,?,?,?) "

     prepare pbdbsa600013 from l_sql

     # ATUALIZA MENSAGENS DA CONTINGENCIA
     let l_sql = " update datmcntmsgctr set ",
                        " prcflg = 'E' ",
                  " where mdtmsgnum = ? "

     prepare pbdbsa600051 from l_sql

     # INCLUI NA TABELA DE MENSAGEM DE TEXTO DO MDT
     let l_sql = " insert into datmmdtmsgtxt ",
                            " (mdtmsgnum, ",
                             " mdtmsgtxtseq, ",
                             " mdtmsgtxt) ",
                      " values(?,?,?) "

     prepare pbdbsa600014 from l_sql

     # INCLUI NA TABELA DE SERVIÇOS/MDT
     let l_sql = " insert into datmmdtsrv ",
                            " (mdtmsgnum, ",
                             " atdsrvnum, ",
                             " atdsrvano) ",
                      " values(?,?,?) "

     prepare pbdbsa600015 from l_sql

     # ATUALIZA MENSAGEM MDT
     let l_sql = " update datmmdtmsg set ",
                       " (mdtmsgstt) = (?) ",
                  " where mdtmsgnum = ? "

     prepare pbdbsa600019 from l_sql

     # ATUALIZA MENSAGEM CONTROLADORA
     let l_sql = " update datmcntmsgctr set ",
                        " prcflg = 'S' ",
                  " where mdtmsgnum = ? "

     prepare pbdbsa600021 from l_sql

     # INCLUI NA TABELA DE LOG DO MDT
     let l_sql = " insert into datmmdtlog ",
                            " (mdtmsgnum, ",
                             " mdtlogseq, ",
                             " mdtmsgstt, ",
                             " atldat, ",
                             " atlhor, ",
                             " atlemp, ",
                             " atlmat, ",
                             " atlusrtip) ",
                      " values(?,?,?,?,?,?,?,?) "

     prepare pbdbsa600018 from l_sql

     # BUSCA QUANTIDADE DE SERVIÇOS POR ASSUNTO
     let l_sql = " select count(c24astcod), ",
                        " c24astcod ",
                   " from datmcntsrv ",
                  " where psccntcod = ? ",
                  " group by 2 ",
                  " order by 1 desc "

     prepare pbdbsa600060 from l_sql
     declare cbdbsa600060 cursor for pbdbsa600060

     # SELECIONA DESCRIÇÃO DO ASSUNTO
     let l_sql = " select c24astdes ",
                   " from datkassunto ",
                  " where c24astcod = ? "

     prepare pbdbsa600061 from l_sql
     declare cbdbsa600061 cursor for pbdbsa600061

     # SELECIONA AGRUPAMENTO DO ASSUNTO - psi230650
     let l_sql = " select c24astagp ",
                   " from datkassunto ",
                  " where c24astcod = ? "
     prepare pbdbsa600062 from l_sql
     declare cbdbsa600062 cursor for pbdbsa600062

     # SELECIONA QUANTIDADE DE SERVIÇOS ABERTO DURANTE CONTINGENCIA - INFORMIX
     let l_sql = " select count(*) ",
                   " from datmcntsrv ",
                  " where psccntcod = ? ",
                    " and atdsrvnum is not null ",
                    " and atdsrvano is not null ",
                    " and dstsrvnum is null ",
                    " and dstsrvano is null "

     prepare pbdbsa600063 from l_sql
     declare cbdbsa600063 cursor for pbdbsa600063

     # SELECIONA QUANTIDADE DE SERVIÇOS ABERTO DURANTE INFORMIX - CONTINGENCIA
     let l_sql = " select count(*) ",
                   " from datmcntsrv ",
                  " where psccntcod = ? ",
                    " and atdsrvnum is null ",
                    " and atdsrvano is null ",
                    " and dstsrvnum is not null ",
                    " and dstsrvano is not null "

     prepare pbdbsa600064 from l_sql
     declare cbdbsa600064 cursor for pbdbsa600064

     # SELECIONA QUANTIDADE DE SERVIÇOS NA CONTINGENCIA
     let l_sql = " select count(*) ",
                   " from datmcntsrv ",
                  " where psccntcod = ? "

     prepare pbdbsa600065 from l_sql
     declare cbdbsa600065 cursor for pbdbsa600065

     let l_sql = " select atdsrvnum, ",
                        " atdsrvano ",
                   " from datmcntsrv ",
                  " where atdsrvnum is not null ",
                    " and atdsrvano is not null ",
                    " and psccntcod = ? ",
                  " union ",
                 " select dstsrvnum, ",
                       " dstsrvano ",
                  " from datmcntsrv ",
                 " where dstsrvnum is not null ",
                   " and dstsrvano is not null ",
                   " and psccntcod = ? "

     prepare pbdbsa600066 from l_sql
     declare cbdbsa600066 cursor for pbdbsa600066

     # SELECIONA QUANTIDADE DE SERVIÇOS NAO PROCESSADOS
     let l_sql = " select count(*) ",
                   " from datmcntsrv ",
                  " where prcflg = 'N' ",
                    " and psccntcod = ? "

     prepare pbdbsa600067 from l_sql
     declare cbdbsa600067 cursor for pbdbsa600067

     # BUSCA CHAVE CONTINGENCIA
     let l_sql = " select grlinf ",
                   " from datkgeral ",
                  " where grlchv = 'PSOCONTINGENCIA'"

     prepare pbdbsa600068 from l_sql
     declare cbdbsa600068 cursor for pbdbsa600068

 end function

#-------------------#
 function bdbsa600()
#-------------------#

 define lr_datmcntsrv record
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
     ciaempcod       like datmcntsrv.ciaempcod
 end record

 define ws      record
     cont       integer                   ,
     hoje       char(10)                  ,
     anochv     char(02)                  ,
     lignum     like datmligacao.lignum   ,
     atdsrvnum  like datmservico.atdsrvnum,
     atdsrvano  like datmservico.atdsrvano,
     sqlcode    integer                   ,
     msg        char(300),
     tabname    char(300)  ,
     atdetpcod  like datmsrvacp.atdetpcod,
     atdfnlflg  like datmservico.atdfnlflg,
     atdfnlhor  like datmservico.atdfnlhor,
     socvclcod  like datkveiculo.socvclcod,
     asitipcod  like datmservico.asitipcod,
     hist1      char(50),
     hist2      char(50),
     hist3      char(50),
     hist4      char(50),
     hist5      char(50),
     histerr    smallint,
     confirma   char(01),
     atdsrvorg  like datmservico.atdsrvorg,
     msglin1    char(1000),
     msglin2    char(1000),
     msglin3    char(1000),
     msglin4    char(2000),
     vcllibflg  like datmservicocmp.vcllibflg,
     roddantxt  like datmservicocmp. roddantxt,
     bocemi     like datmservicocmp. bocemi,
     sinvitflg  like datmservicocmp.sinvitflg,
     bocflg     like datmservicocmp.bocflg,
     bocnum     like datmservicocmp.bocnum,
     passeq     like datmpassageiro.passeq,
     msglog     char (500),
     acheidocto char (1),
     tempo      datetime year to second,
     tempo1     datetime year to second,
     atddatprg  like datmservico.atddatprg,
     atdhorprg  like datmservico.atdhorprg,
     sinvstnum  like datmpedvist.sinvstnum,
     promptX    char(01),
     sinntzcod  like datmavssin.sinntzcod,
     resultado  smallint
 end record

 define l_aux          record
                           msg_erro         char(40)
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

 define l_ramgrpcod      like gtakram.ramgrpcod,
        m_bnfnum         like datrligsau.bnfnum,
        m_succod         like datksegsau.succod,
        m_ramcod         like datksegsau.ramcod,
        m_aplnumdig      like datksegsau.aplnumdig,
        l_socvclcod      like datkveiculo.socvclcod,
        l_primeira_letra char(01),
        l_resto_cor      char(19),
        l_char_vclanomdl char(04),
        l_nulo           char(01),
        l_num_char       char(01),
        l_char_funmat    char(06),
        l_char_c24opemat char(10),
        l_ins_etapa      smallint,
        l_calcula_ano    smallint,
        l_zero           smallint,
        l_tres           smallint,
        l_processo_ok    smallint,
        l_fim_ano        decimal(2,0),
        l_cpocod         decimal(2,0),
        l_contingencia   char(10),
        l_c24astagp      like datkassunto.c24astagp   #psi230650

   # VERIFICA CONTINGENCIA ATIVA
   open cbdbsa600068
   fetch cbdbsa600068 into l_contingencia

   display l_contingencia

   if  not l_contingencia = "ATIVA" then

       # VERIFICA SE E AMBIENTE DE TESTE OU PRODUCAO - FUNCAO CORPORATIVA(EVANDO PEREIRA)
       if not figrc012_sitename("ofcea060","","") then
          display "ERRO NO ACESSO SITENAME DA DUAL!. AVISE A INFORMATICA !" sleep 5
          return
       end if

       # ABRE O CURSOR PRINCIPAL DOS REGISTROS DA CONTINGENCIA
       open cbdbsa600001
       foreach cbdbsa600001 into lr_datmcntsrv.seqreg
                                ,lr_datmcntsrv.seqregcnt
                                ,lr_datmcntsrv.atdsrvorg
                                ,lr_datmcntsrv.atdsrvnum
                                ,lr_datmcntsrv.atdsrvano
                                ,lr_datmcntsrv.srvtipabvdes
                                ,lr_datmcntsrv.atdnom
                                ,lr_datmcntsrv.funmat
                                ,lr_datmcntsrv.asitipabvdes
                                ,lr_datmcntsrv.c24solnom
                                ,lr_datmcntsrv.vcldes
                                ,lr_datmcntsrv.vclanomdl
                                ,lr_datmcntsrv.vclcor
                                ,lr_datmcntsrv.vcllicnum
                                ,lr_datmcntsrv.vclcamtip
                                ,lr_datmcntsrv.vclcrgflg
                                ,lr_datmcntsrv.vclcrgpso
                                ,lr_datmcntsrv.atddfttxt
                                ,lr_datmcntsrv.segnom
                                ,lr_datmcntsrv.aplnumdig
                                ,lr_datmcntsrv.cpfnum
                                ,lr_datmcntsrv.ocrufdcod
                                ,lr_datmcntsrv.ocrcidnom
                                ,lr_datmcntsrv.ocrbrrnom
                                ,lr_datmcntsrv.ocrlgdnom
                                ,lr_datmcntsrv.ocrendcmp
                                ,lr_datmcntsrv.ocrlclcttnom
                                ,lr_datmcntsrv.ocrlcltelnum
                                ,lr_datmcntsrv.ocrlclrefptotxt
                                ,lr_datmcntsrv.dsttipflg
                                ,lr_datmcntsrv.dstufdcod
                                ,lr_datmcntsrv.dstcidnom
                                ,lr_datmcntsrv.dstbrrnom
                                ,lr_datmcntsrv.dstlgdnom
                                ,lr_datmcntsrv.rmcacpflg
                                ,lr_datmcntsrv.obstxt
                                ,lr_datmcntsrv.srrcoddig
                                ,lr_datmcntsrv.srrabvnom
                                ,lr_datmcntsrv.atdvclsgl
                                ,lr_datmcntsrv.atdprscod
                                ,lr_datmcntsrv.nomgrr
                                ,lr_datmcntsrv.atddat
                                ,lr_datmcntsrv.atdhor
                                ,lr_datmcntsrv.acndat
                                ,lr_datmcntsrv.acnhor
                                ,lr_datmcntsrv.acnprv
                                ,lr_datmcntsrv.c24openom
                                ,lr_datmcntsrv.c24opemat
                                ,lr_datmcntsrv.pasnom1
                                ,lr_datmcntsrv.pasida1
                                ,lr_datmcntsrv.pasnom2
                                ,lr_datmcntsrv.pasida2
                                ,lr_datmcntsrv.pasnom3
                                ,lr_datmcntsrv.pasida3
                                ,lr_datmcntsrv.pasnom4
                                ,lr_datmcntsrv.pasida4
                                ,lr_datmcntsrv.pasnom5
                                ,lr_datmcntsrv.pasida5
                                ,lr_datmcntsrv.atldat
                                ,lr_datmcntsrv.atlhor
                                ,lr_datmcntsrv.atlmat
                                ,lr_datmcntsrv.atlnom
                                ,lr_datmcntsrv.cnlflg
                                ,lr_datmcntsrv.cnldat
                                ,lr_datmcntsrv.cnlhor
                                ,lr_datmcntsrv.cnlmat
                                ,lr_datmcntsrv.cnlnom
                                ,lr_datmcntsrv.socntzcod
                                ,lr_datmcntsrv.c24astcod
                                ,lr_datmcntsrv.atdorgsrvnum
                                ,lr_datmcntsrv.atdorgsrvano
                                ,lr_datmcntsrv.srvtip
                                ,lr_datmcntsrv.acnifmflg
                                ,lr_datmcntsrv.dstsrvnum
                                ,lr_datmcntsrv.dstsrvano
                                ,lr_datmcntsrv.prcflg
                                ,lr_datmcntsrv.ramcod
                                ,lr_datmcntsrv.succod
                                ,lr_datmcntsrv.itmnumdig
                                ,lr_datmcntsrv.ocrlcldddcod
                                ,lr_datmcntsrv.cpfdig
                                ,lr_datmcntsrv.cgcord
                                ,lr_datmcntsrv.ocrendzoncod
                                ,lr_datmcntsrv.dstendzoncod
                                ,lr_datmcntsrv.sindat
                                ,lr_datmcntsrv.sinhor
                                ,lr_datmcntsrv.bocnum
                                ,lr_datmcntsrv.boclcldes
                                ,lr_datmcntsrv.sinavstip
                                ,lr_datmcntsrv.vclchscod
                                ,lr_datmcntsrv.obscmptxt
                                ,lr_datmcntsrv.crtsaunum
                                ,lr_datmcntsrv.ciaempcod

          let m_curr = current
          display "[", m_curr, "] VALIDANDO SERVICO: ", lr_datmcntsrv.atdsrvnum,lr_datmcntsrv.atdsrvano using "&&"

          begin work

          # SE FOR NULL SIGNIFICA QUE A CARGA DO ASP NAO CARREGOU A EMPRESA,
          # NESTE CASO O SISTEMA DEVE ASSUMIR PORTO.
          if lr_datmcntsrv.ciaempcod is null  or
             lr_datmcntsrv.ciaempcod = "  "   then
             let lr_datmcntsrv.ciaempcod = 1
          end if

          # O ASP CARREGA BRANCO O LAUDO ENTENDE NULL, CORRIGIDO EM 17/05
          if lr_datmcntsrv.ocrendzoncod  =  "  " then
             let lr_datmcntsrv.ocrendzoncod = null
          end if
          if lr_datmcntsrv.dstendzoncod  =  "  " then
             let lr_datmcntsrv.dstendzoncod = null
          end if

          # VALIDACAO DA MATRICULA
          let l_char_funmat = lr_datmcntsrv.funmat
          if length(l_char_funmat) = 6 then  # ex. 101476
             let lr_datmcntsrv.funmat = l_char_funmat[2,6]
          end if

          # VALIDA USUARIO
          if lr_datmcntsrv.c24opemat is not null and
             lr_datmcntsrv.c24opemat <> " " then
             let l_char_c24opemat = lr_datmcntsrv.c24opemat
             if length(l_char_c24opemat)  = 6 then
                let lr_datmcntsrv.c24opemat = l_char_c24opemat[2,6]
             end if
          end if

          # DADOS DA APOLICE
          open cbdbsa600002 using lr_datmcntsrv.atdvclsgl
          whenever error continue
          fetch cbdbsa600002 into l_socvclcod
          whenever error stop

          if sqlca.sqlcode <> 0 then
             let l_socvclcod = null
          end if

          close cbdbsa600002

          # QUANDO SERVICO NAO FOR NULO ELE FOI ALTERADO PELA CONTIGENCIA
          # OBS: QUANDO O ASSUNTO FOR V12 OU F10 O SERVICO E NULO
          if lr_datmcntsrv.atdsrvnum is not null then

             let m_curr = current
             display "[", m_curr, "] VERIFICANDO SE O SERVICO EXISTE NA DATMSERVICO"

             # VERIFICA SE O SERVICO EXISTE NA DATMSERVICO
             open cbdbsa600041 using lr_datmcntsrv.atdsrvnum, lr_datmcntsrv.atdsrvano
             whenever error continue
             fetch cbdbsa600041
             whenever error stop

             if sqlca.sqlcode <> 0 then

                # ATUALIZA PRCFLG = "s"
                whenever error continue
                execute pbdbsa600024 using lr_datmcntsrv.seqreg
                whenever error stop

                let m_curr = current

                if sqlca.sqlcode <> 0 then
                   display "[", m_curr, "] Erro de UPDATE na tabela datmcntsrv - 1"
                   rollback  work
                   continue foreach
                end if

                let ws.msglin1 = "[", m_curr, "] O SERVICO: ",
                                 lr_datmcntsrv.atdsrvnum using "<<<<<<<<<&", "-",
                                 lr_datmcntsrv.atdsrvano using "&&",
                                 " NAO EXISTE NA DATMSERVICO."

                display ws.msglin1
                close cbdbsa600041
                commit work
                continue foreach
             end if

             close cbdbsa600041

             if lr_datmcntsrv.atdprscod is not null and
                lr_datmcntsrv.atdprscod <> 0   then # acionado

                let m_curr = current
                display "[", m_curr, "] INSERINDO ETAPA 1"

                # ATUALIZACAO DA TABELA DATMSERVICO/ETAPA
                execute pbdbsa600003 using lr_datmcntsrv.atdprscod
                                          ,l_socvclcod
                                          ,lr_datmcntsrv.srrcoddig
                                          ,lr_datmcntsrv.srrabvnom
                                          ,lr_datmcntsrv.acnhor
                                          ,lr_datmcntsrv.c24opemat
                                          ,lr_datmcntsrv.acndat
                                          ,lr_datmcntsrv.atdsrvnum
                                          ,lr_datmcntsrv.atdsrvano
                if sqlca.sqlcode <> 0 then
                   let m_curr = current
                   display "[", m_curr, "] Erro de UPDATE na tabela datmservico"
                   rollback work
                   continue foreach
                else
                   call cts00g07_apos_grvlaudo(lr_datmcntsrv.atdsrvnum,
                                               lr_datmcntsrv.atdsrvano)
                end if

                # GRAVAR ETAPA DO SERVICO
                let ws.atdetpcod = 4

                # PARA ASSUNTOS DA AZUL A ETAPA E 4, NAO EXISTE ETAPA DE RE
                if lr_datmcntsrv.ciaempcod = 1 then
                   if lr_datmcntsrv.c24astcod = "S60" or
                      lr_datmcntsrv.c24astcod = "S63" or
                      lr_datmcntsrv.c24astcod = "S13" or
                      lr_datmcntsrv.c24astcod = "S47" or
                      lr_datmcntsrv.c24astcod = "S62" or
                      lr_datmcntsrv.c24astcod = "S64" then
                      let ws.atdetpcod = 3
                   end if
                end if

                # -> NAO UTILIZAR A FUNCAO PADRAO, POIS ELA INSERE DATA E HORA ATUAL
                # -> O CORRETO E INSERIR DATA E HORA DA TABELA datmcntsrv
                call bdbsa600_insere_etapa(lr_datmcntsrv.atdsrvnum,
                                           lr_datmcntsrv.atdsrvano,
                                           ws.atdetpcod,
                                           lr_datmcntsrv.atldat,
                                           lr_datmcntsrv.atlhor,
                                           1,                      # EMPCOD
                                           lr_datmcntsrv.funmat,
                                           lr_datmcntsrv.atdprscod,
                                           lr_datmcntsrv.srrcoddig,
                                           l_socvclcod,
                                           lr_datmcntsrv.srrabvnom)
                     returning l_ins_etapa

                if l_ins_etapa <> 0 then
                   let m_curr = current
                   display "[", m_curr, "] Problema na atualizacao da etapa na tabela datmservico() - 1"
                   rollback work
                   continue foreach
                end if

                if lr_datmcntsrv.cnlflg = "S" then # SERVICO ACIONADO E CANCELADO.

                   # -> NAO UTILIZAR A FUNCAO PADRAO, POIS ELA INSERE DATA E HORA ATUAL
                   # -> O CORRETO E INSERIR DATA E HORA DA TABELA DATMCNTSRV
                   call bdbsa600_insere_etapa(lr_datmcntsrv.atdsrvnum,
                                              lr_datmcntsrv.atdsrvano,
                                              5,   # ---> ATDETPCOD
                                              lr_datmcntsrv.atldat,
                                              lr_datmcntsrv.atlhor,
                                              1,   # ---> EMPCOD
                                              lr_datmcntsrv.funmat,
                                              lr_datmcntsrv.atdprscod,
                                              lr_datmcntsrv.srrcoddig,
                                              l_socvclcod,
                                              lr_datmcntsrv.srrabvnom)
                        returning l_ins_etapa

                   if l_ins_etapa <> 0 then
                      let m_curr = current
                      display "[", m_curr, "] Erro ao chamar a funcao bdbsa600_insere_etapa() - 2"
                      rollback work
                      continue foreach
                   end if
                end if

                if lr_datmcntsrv.cnlflg = "S"  then   # SERVICO CANCELADO
                   # SERVICO DO IFX NAO ACIONADO NA CONTINGENCIA
                   # FLAG "s" PARA NAO APARECER NO RADIO.
                   whenever error continue
                   execute pbdbsa600023 using lr_datmcntsrv.atdsrvnum,
                                              lr_datmcntsrv.atdsrvano
                   whenever error stop

                   let m_curr = current
                   if sqlca.sqlcode <> 0 then
                      display "[", m_curr, "] Erro de UPDATE na tabela datmservico - 1"
                      rollback work
                      continue foreach
                   else
                       call cts00g07_apos_grvlaudo(lr_datmcntsrv.atdsrvnum,
                                                   lr_datmcntsrv.atdsrvano)
                   end if

                   display "[", m_curr, "] SERVICO CANCELADO"

                   # -> NAO UTILIZAR A FUNCAO PADRAO, POIS ELA INSERE DATA E HORA ATUAL
                   # -> O CORRETO E INSERIR DATA E HORA DA TABELA datmcntsrv
                   call bdbsa600_insere_etapa(lr_datmcntsrv.atdsrvnum,
                                              lr_datmcntsrv.atdsrvano,
                                              5,     # ---> ATDETPCOD
                                              lr_datmcntsrv.atldat,
                                              lr_datmcntsrv.atlhor,
                                              1,     # ---> EMPCOD
                                              lr_datmcntsrv.funmat,
                                              lr_datmcntsrv.atdprscod,
                                              lr_datmcntsrv.srrcoddig,
                                              l_socvclcod,
                                              lr_datmcntsrv.srrabvnom)
                        returning l_ins_etapa

                   if l_ins_etapa <> 0 then
                      let m_curr = current
                      display "[", m_curr, "] Erro ao chamar a funcao bdbsa600_insere_etapa() - 3"
                      rollback work
                      continue foreach
                   end if
                end if
             end if

             whenever error continue
             execute pbdbsa600024 using lr_datmcntsrv.seqreg
             whenever error stop

             if sqlca.sqlcode <> 0 then
                let m_curr = current
                display "[", m_curr, "] Erro de UPDATE na tabela datmcntsrv - 2"
                rollback work
             end if
          end if
          # FIM DAS ROTINAS COMUM A PORTO E AZUL

          # O SERVIÇO SERA GERADO PELA CONTINGENCIA
          if lr_datmcntsrv.atdsrvnum is null  then

             if lr_datmcntsrv.ciaempcod = 35 then   # AZUL SEGUROS

                # PESQUISA POR APOLICE, PLACA E CGCCPF
                initialize g_documento,
                           l_aux.msg_erro to null

                call cts35m04_PesquisaApoliceAzul(lr_datmcntsrv.seqreg,
                                                  lr_datmcntsrv.funmat,
                                                  lr_datmcntsrv.c24opemat)
                     returning ws.msg,
                               ws.resultado,
                               lr_cts05g00.segnom,
                               lr_cts05g00.corsus,
                               lr_cts05g00.cornom,
                               lr_cts05g00.cvnnom,
                               lr_cts05g00.vclcoddig,
                               lr_cts05g00.vclchsinc,
                               lr_cts05g00.vclchsfnl,
                               lr_datmcntsrv.vcldes,
                               lr_datmcntsrv.vclanomdl,
                               lr_datmcntsrv.vcllicnum

                let m_curr = current
                display "[", m_curr, "] BUSCANDO DADOS DA AZUL SEGUROS"

                if ws.resultado = 1 then
                   let ws.acheidocto = "S"
                   let g_documento.edsnumref = 0
                else
                   let ws.acheidocto = "N"
                end if
             end if

             if lr_datmcntsrv.ciaempcod = 1 then  # PORTO SEGURO

                # PESQUISA APOLICE PARA PORTO
                initialize g_documento, l_aux.msg_erro to null

                let ws.acheidocto         = "N"
                let g_documento.edsnumref = 0

                # APOLICE
                if lr_datmcntsrv.ramcod is not null    and
                   lr_datmcntsrv.ramcod <> 0           then

                   # PSI 202720 - OBTER O CARTAO SAUDE
                   call cty10g00_grupo_ramo(1, lr_datmcntsrv.ramcod)
                        returning m_status, m_msg, l_ramgrpcod

                   if l_ramgrpcod = 5 then ## SAUDE

                     call cta01m15_sel_datksegsau(6,lr_datmcntsrv.crtsaunum,"","","")
                           returning m_status, m_msg, m_crtsaunum, m_bnfnum

                      if m_status = 1 then
                         let ws.acheidocto = "S"
                         let g_documento.crtsaunum = m_crtsaunum
                         let g_documento.bnfnum    = m_bnfnum

                         # BUSCA NUMERO DO CARTAO P/ GRAVAR DATRSRVSAU
                         open cbdbsa600053 using g_documento.crtsaunum
                         fetch cbdbsa600053 into m_succod,
                                                 m_ramcod,
                                                 m_aplnumdig
                         close cbdbsa600053
                      end if
                   else
                      if lr_datmcntsrv.succod    is not null and
                         lr_datmcntsrv.succod <> 0           and
                         lr_datmcntsrv.aplnumdig is not null and
                         lr_datmcntsrv.aplnumdig <> 0        and
                         lr_datmcntsrv.itmnumdig is not null then

                         # EM APOLICE DO RE O ITEM E ZERO
                         let l_aux.msg_erro = bdbsa600_apolice(lr_datmcntsrv.ramcod
                                                              ,lr_datmcntsrv.succod
                                                              ,lr_datmcntsrv.aplnumdig
                                                              ,lr_datmcntsrv.itmnumdig)
                         if l_aux.msg_erro is null then
                            let ws.acheidocto = "S"
                         end if

                      end if
                   end if
                end if

                if ws.acheidocto = "N" then
                   initialize l_aux.msg_erro to null
                   --[ placa ]
                   if lr_datmcntsrv.vcllicnum is not null  and
                      lr_datmcntsrv.vcllicnum <> "       " and  # 7P. CAMPO TABELA
                      l_ramgrpcod            <> 5         then  # GRUPO 5 = SAUDE

                      let m_curr = current
                      display "[", m_curr, "] BUSCA A PLACA : ", lr_datmcntsrv.vcllicnum

                      let l_aux.msg_erro = bdbsa600_placa(lr_datmcntsrv.vcllicnum)

                      if l_aux.msg_erro is null then
                         let ws.acheidocto = "S"
                         let m_curr = current
                         display "[", m_curr, "] ACHOU ATRAVES DA PLACA"
                      end if
                   end if

                   if ws.acheidocto = "N" then
                      initialize l_aux.msg_erro to null

                      # CPF
                      if lr_datmcntsrv.cpfnum is not null and
                         lr_datmcntsrv.cpfnum <> 0        then

                         call bdbsa600_cgccpf(lr_datmcntsrv.cpfnum
                                             ,lr_datmcntsrv.cgcord
                                             ,lr_datmcntsrv.cpfdig
                                             ,lr_datmcntsrv.ramcod
                                             ,l_ramgrpcod ) ## PSI 272720
                           returning l_aux.msg_erro

                         if l_aux.msg_erro is null then
                            let ws.acheidocto = "S"
                            let m_curr = current
                            display "[", m_curr, "] ACHOU ATRAVES DO CPF"
                         end if
                      end if

                      if ws.acheidocto = "N" then

                         # PESQUISA CARTAO SAUDE POR NOME
                         if l_ramgrpcod = 5 and
                            lr_datmcntsrv.segnom is not null then

                            call bdbsa600_nome(lr_datmcntsrv.segnom)
                                 returning l_aux.msg_erro

                            if l_aux.msg_erro is null then
                               let ws.acheidocto = "S"
                               let m_curr = current
                               display "[", m_curr, "] ACHOU NOME DO SEGURADO CARTAO"
                            end if
                         end if
                      end if
                   end if
                end if
             end if

             if g_documento.aplnumdig is not null  and
                g_documento.aplnumdig <> 0        then

                if g_documento.succod    is null or
                   g_documento.itmnumdig is null then


                   let m_curr = current
                   let ws.msglog = "[", m_curr, "] ** bdbsa600-item ou suc nulo, reg= ",
                                   lr_datmcntsrv.seqreg

                   display ws.msglog
                   initialize g_documento to null
                end if
             end if

             if lr_datmcntsrv.c24astcod = "V12" then

                let m_curr = current
                display "[", m_curr, "] INICIANDO A INCLUSAO DO V12"

                commit work

                call cts35m01(lr_datmcntsrv.seqreg,
                              lr_datmcntsrv.funmat,
                              lr_datmcntsrv.c24opemat,
                              g_documento.succod,
                              g_documento.ramcod,
                              g_documento.aplnumdig,
                              g_documento.itmnumdig)
                     returning ws.msg,
                               ws.sqlcode,
                               ws.sinvstnum

                if ws.sqlcode <> 0 then

                   let m_curr = current
                   let ws.msg  = "[", m_curr, "] ", ws.msg clipped, " ",
                                   "problemas na funcao cts35m01"

                   display ws.msg
                end if
                continue foreach
             end if

             let ws.atdsrvorg = 1

             ##PSI 230650 - inicio
             #Buscar agrupamento do assunto
             open cbdbsa600062 using lr_datmcntsrv.c24astcod
             whenever error continue
             fetch cbdbsa600062 into l_c24astagp
             whenever error stop

             if sqlca.sqlcode = notfound then
                let l_cpocod = 0
             end if

             close cbdbsa600062
             ##PSI 230650 - fim

             if lr_datmcntsrv.c24astcod = "S60" or
                lr_datmcntsrv.c24astcod = "S63" or
                lr_datmcntsrv.c24astcod = "S13" or
                lr_datmcntsrv.c24astcod = "S47" or
                lr_datmcntsrv.c24astcod = "S62" or
                lr_datmcntsrv.c24astcod = "S64" then
                let ws.atdsrvorg = 9
             end if

             if lr_datmcntsrv.c24astcod = "S23"  or
                lr_datmcntsrv.c24astcod = "S53"  or
                lr_datmcntsrv.c24astcod = "K23"  or
                lr_datmcntsrv.c24astcod = "K53"  or
                lr_datmcntsrv.c24astcod = "K93"  then
                let ws.atdsrvorg = 2
             end if

             if lr_datmcntsrv.c24astcod = "S33"  or
                lr_datmcntsrv.c24astcod = "K14"  or
                lr_datmcntsrv.c24astcod = "K33"  or
                lr_datmcntsrv.c24astcod = "K93"  then
                let ws.atdsrvorg = 3
             end if

             if lr_datmcntsrv.c24astcod = "D13" then
                let ws.atdsrvorg = 6
             end if

             #if lr_datmcntsrv.c24astcod[1] = "G"   or
             if l_c24astagp = "G"   or                   ## psi230650
                lr_datmcntsrv.c24astcod    = "F13" or
                lr_datmcntsrv.c24astcod    = "I10" or
                lr_datmcntsrv.c24astcod    = "L10" or
                lr_datmcntsrv.c24astcod    = "E10" or
                lr_datmcntsrv.c24astcod    = "K17" or #AMILTON
                lr_datmcntsrv.c24astcod    = "K18" or #AMILTON
                lr_datmcntsrv.c24astcod    = "K19" or #AMILTON
                lr_datmcntsrv.c24astcod    = "K21" or #AMILTON
                lr_datmcntsrv.c24astcod    = "K37" or
                lr_datmcntsrv.c24astcod    = "K15" then
                let ws.atdsrvorg = 4
             end if

             if lr_datmcntsrv.c24astcod    = "F10" then
                let ws.atdsrvorg = 11
             end if

             if ws.atdsrvorg <> 9 then

                # VALIDACAO DO CODIGO DA COR DO VEICULO
                # NA TELA DA CONTINGENCIA(ASP) A COR DO VEICULO E MAISCULA
                let l_primeira_letra = lr_datmcntsrv.vclcor[1]
                let l_resto_cor      = lr_datmcntsrv.vclcor[2,20]
                let l_resto_cor      = downshift(l_resto_cor)

                # MONTAGEM DA COR:PRIMEIRA LETRA MAIUSCULA RESTANTES MINUSCULAS #
                let lr_datmcntsrv.vclcor = l_primeira_letra, l_resto_cor

                let lr_cts05g00.vclcoddig = 99999

                # VERIFICA SE TEMOS APOLICE
                if g_documento.aplnumdig is not null and
                   g_documento.aplnumdig <> 0        then

                   # BUSCA OS DADOS DO VEICULO DA APOLICE
                   if lr_datmcntsrv.ciaempcod = 1 then # PORTO
                      call cts05g00(g_documento.succod,
                                    g_documento.ramcod,
                                    g_documento.aplnumdig,
                                    g_documento.itmnumdig)

                           returning lr_cts05g00.segnom,
                                     lr_cts05g00.corsus,
                                     lr_cts05g00.cornom,
                                     lr_cts05g00.cvnnom,
                                     lr_cts05g00.vclcoddig,
                                     lr_datmcntsrv.vcldes,
                                     lr_datmcntsrv.vclanomdl,
                                     lr_datmcntsrv.vcllicnum,
                                     lr_cts05g00.vclchsinc,
                                     lr_cts05g00.vclchsfnl,
                                     lr_datmcntsrv.vclcor

                   end if
                else
                   # VALIDACAO DO ANO DO VEICULO
                   let l_char_vclanomdl = lr_datmcntsrv.vclanomdl
                   let l_fim_ano        = l_char_vclanomdl[3,4]

                   if l_fim_ano > 50 then
                      let l_calcula_ano = (1900 + l_fim_ano)
                   end if

                   if l_fim_ano <= 50 then
                      let l_calcula_ano = (2000 + l_fim_ano)
                   end if

                   let l_char_vclanomdl       = l_calcula_ano
                   let lr_datmcntsrv.vclanomdl = l_char_vclanomdl
                end if

                open cbdbsa600025 using lr_datmcntsrv.vclcor
                whenever error continue
                fetch cbdbsa600025 into l_cpocod
                whenever error stop

                if sqlca.sqlcode = notfound then
                   let l_cpocod = 0
                end if

                close cbdbsa600025
             end if

             # GERAR AVISO QDO NAO LOCALIZAR APOLICE - SILMARA 22/01/07
             if lr_datmcntsrv.c24astcod = "F10"    then
                commit work
                call cts35m03(lr_datmcntsrv.seqreg,
                              lr_datmcntsrv.funmat,
                              lr_datmcntsrv.c24opemat,
                              g_documento.succod,
                              g_documento.ramcod,
                              g_documento.aplnumdig,
                              g_documento.itmnumdig,
                              ws.atdsrvorg         ,
                              lr_datmcntsrv.vclanomdl,
                              l_cpocod)
                     returning ws.msg,
                               ws.sqlcode,
                               ws.atdsrvnum,
                               ws.atdsrvano

                if ws.sqlcode <> 0 then
                   let m_curr = current
                   let ws.msg  = "[", m_curr, "] ", ws.msg clipped, " ",
                                   "problemas na funcao cts35m03"
                   display ws.msg
                end if

                execute pbdbsa600033 using ws.atdsrvnum,
                                           ws.atdsrvano,
                                           lr_datmcntsrv.seqreg

                continue foreach
             end if

             let ws.asitipcod = 1

             if lr_datmcntsrv.asitipabvdes = "Chaveiro" then
                let ws.asitipcod = 4
             end if

             if lr_datmcntsrv.asitipabvdes = "Tecnico"  then
                let ws.asitipcod = 2
             end if

             if lr_datmcntsrv.asitipabvdes = "Guincho"  then
                let ws.asitipcod = 1
             end if

             if lr_datmcntsrv.asitipabvdes = "Gui/Tecnico" then
                let ws.asitipcod = 3
             end if

             if lr_datmcntsrv.asitipabvdes = "Taxi"     then
                let ws.asitipcod = 5
             end if

             if lr_datmcntsrv.asitipabvdes = "Hospedag" then
                let ws.asitipcod = 5
             end if

             if lr_datmcntsrv.asitipabvdes = "Passagem" then
                let ws.asitipcod = 10
             end if

             if lr_datmcntsrv.asitipabvdes = "R.E." or
                lr_datmcntsrv.asitipabvdes = "RE" then
                let ws.asitipcod = 6
             end if

             let ws.atdetpcod = 1
             let ws.atdfnlflg = "N"
             let ws.atdfnlhor = null

             if lr_datmcntsrv.atdprscod is not null and
                lr_datmcntsrv.atdprscod <> 0        then #-->Serviço Acionado
                let ws.atdfnlflg = "S"
                let ws.atdfnlhor = lr_datmcntsrv.acnhor
                let ws.atdetpcod = 4
                if lr_datmcntsrv.c24astcod = "S60" or
                   lr_datmcntsrv.c24astcod = "S63" or
                   lr_datmcntsrv.c24astcod = "S13" or
                   lr_datmcntsrv.c24astcod = "S47" or
                   lr_datmcntsrv.c24astcod = "S62" or
                   lr_datmcntsrv.c24astcod = "S64" then
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

                let m_curr = current
                let ws.msg = "[", m_curr, "] ", ws.msg clipped, " ",
                             "chamada da funcao cts10g03_numeracao()"

                display ws.msg
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
                   # ATUALIZA DATRSERVAPOL
                   execute pbdbsa600026 using ws.atdsrvnum,
                                              ws.atdsrvano,
                                              g_documento.succod,
                                              g_documento.ramcod,
                                              g_documento.aplnumdig,
                                              g_documento.itmnumdig,
                                              g_documento.edsnumref
                   whenever error stop
                   if sqlca.sqlcode <> 0  then
                      let m_curr = current
                      display "[", m_curr, "] Erro de INSERT na tabela datrservapol"
                      rollback work
                      continue foreach
                   end if
                else
                 if g_documento.crtsaunum is not null and
                    g_documento.crtsaunum <> 0        then
                   execute pbdbsa600052 using ws.atdsrvnum,
                                              ws.atdsrvano,
                                              m_succod,
                                              m_ramcod,
                                              m_aplnumdig,
                                              g_documento.crtsaunum,
                                              g_documento.bnfnum
                   whenever error stop
                   if sqlca.sqlcode <> 0  then
                      let m_curr = current
                      display "[", m_curr, "] Erro de INSERT na tabela datrsrvsau"
                      rollback work
                      continue foreach
                   end if
                 end if
                end if
             end if

             call cts10g00_ligacao
                   ( ws.lignum              ,#
                     lr_datmcntsrv.atldat   ,#
                     lr_datmcntsrv.atlhor   ,#
                     1                      ,# C24SOLTIPCOD
                     lr_datmcntsrv.c24solnom,#
                     lr_datmcntsrv.c24astcod,#
                     lr_datmcntsrv.funmat   ,#
                     0                      ,# LIGCVNTIP
                     0                      ,# C24PAXNUM
                     ws.atdsrvnum           ,#
                     ws.atdsrvano           ,#
                     ""                     ,# SINVSTNUM
                     ""                     ,# SINVSTANO
                     ""                     ,# SINAVSNUM
                     ""                     ,# SINAVSANO
                     g_documento.succod     ,#
                     g_documento.ramcod     ,#
                     g_documento.aplnumdig  ,#
                     g_documento.itmnumdig  ,#
                     g_documento.edsnumref  ,#
                     g_documento.prporg     ,#
                     g_documento.prpnumdig  ,#
                     g_documento.fcapacorg  ,#
                     g_documento.fcapacnum  ,#
                     ""                     ,# SINRAMCOD
                     ""                     ,# SINANO
                     ""                     ,# SINNUM
                     ""                     ,# SINITMSEQ
                     today                  ,# CADDAT
                     current hour to minute ,# CADHOR
                     1                      ,# CADEMP
                     lr_datmcntsrv.funmat   )# CADMAT
                 returning ws.tabname,
                           ws.sqlcode

             if ws.sqlcode  <>  0  then
                let ws.tabname = ws.tabname clipped, " --> TABELA , chamada da funcao cts10g00_ligacao()"
                let m_curr = current
                display "[", m_curr, "] ", ws.tabname
                rollback work
                continue foreach
             end if

             #VERIFICA SE O SERVICO E PROGRAMADO
             let ws.atddatprg = null
             let ws.atdhorprg = null
             if (lr_datmcntsrv.atddat > today) or
                (lr_datmcntsrv.atddat = today  and
                 lr_datmcntsrv.atdhor > current hour to minute) then
                 let ws.atddatprg = lr_datmcntsrv.atddat
                 let ws.atdhorprg = lr_datmcntsrv.atdhor
             end if

             call cts10g02_grava_servico
                  ( ws.atdsrvnum,
                    ws.atdsrvano,
                    1 ,
                    lr_datmcntsrv.c24solnom,
                    l_cpocod,
                    lr_datmcntsrv.funmat ,
                    "S",
                    lr_datmcntsrv.atlhor ,
                    lr_datmcntsrv.atldat,
                    lr_datmcntsrv.atldat,
                    lr_datmcntsrv.atlhor,
                    "",
                    "00:00",
                    ws.atddatprg,
                    ws.atdhorprg,
                    3 ,
                    "",
                    "",
                    lr_datmcntsrv.atdprscod,
                    "",
                    ws.atdfnlflg,
                    ws.atdfnlhor,
                    "N",
                    lr_datmcntsrv.atddfttxt,  # D_CTS03M00.ATDDFTTXT,
                    ""                    ,   # ATDDOCTXT
                    lr_datmcntsrv.c24opemat , # W_CTS03M00.C24OPEMAT,
                    lr_datmcntsrv.segnom    , # D_CTS03M00.NOM      ,
                    lr_datmcntsrv.vcldes    , # D_CTS03M00.VCLDES   ,
                    lr_datmcntsrv.vclanomdl , # D_CTS03M00.VCLANOMDL,
                    lr_datmcntsrv.vcllicnum , # D_CTS03M00.VCLLICNUM,
                    lr_cts05g00.corsus     ,  # D_CTS03M00.CORSUS   ,
                    lr_cts05g00.cornom     ,  # D_CTS03M00.CORNOM   ,
                    lr_datmcntsrv.acndat    , # W_CTS03M00.CNLDAT   ,
                    ""                     ,  # PGTDAT
                    lr_datmcntsrv.srrabvnom , # W_CTS03M00.C24NOMCTT,
                    "N"                    ,  # W_CTS03M00.ATDPVTRETFLG,
                    ""                     ,  # W_CTS03M00.ATDVCLTIP,
                    ws.asitipcod           ,  # D_CTS03M00.ASITIPCOD ,
                    l_socvclcod            ,  # SOCVCLCOD
                    lr_cts05g00.vclcoddig  ,  # D_CTS03M00.VCLCODDIG,
                    "N"                    ,  # D_CTS03M00.SRVPRLFLG,
                    lr_datmcntsrv.srrcoddig,  # SRRCODDIG
                    1                      ,  # D_CTS03M00.ATDPRINVLCOD,
                    ws.atdsrvorg )            # D_CTS03M00.ATDSRVORG)
             returning ws.tabname,
                       ws.sqlcode

             if ws.sqlcode <> 0 then
                let ws.tabname = ws.tabname clipped, " --> TABELA , chamada da funcao cts10g02_grava_servico()"
                let m_curr = current
                display "[", m_curr, "] ", ws.tabname
                rollback work
                continue foreach
             end if

             if lr_datmcntsrv.atddfttxt is not null and
                lr_datmcntsrv.atddfttxt <> " "      then
                # GRAVA DESCRICAO DO PROBLEMA(DATRSRVPBM)
                call ctx09g02_inclui(ws.atdsrvnum,
                                     ws.atdsrvano,
                                     1      ,                # ORG. INFORMACAO 1-SEGURADO 2-PST
                                     999                 ,
                                     lr_datmcntsrv.atddfttxt,
                                     ""                  )   # CODIGO PRESTADOR
                     returning ws.sqlcode, ws.tabname

                if ws.sqlcode <> 0 then
                   let ws.tabname = ws.tabname clipped, " --> TABELA , chamada da funcao  ()"
                   let m_curr = current
                   display "[", m_curr, "] ", ws.tabname
                   rollback work
                   continue foreach
               end if
             end if

             # INSERIR COMPLEMENTO DO SERVICO
             if lr_datmcntsrv.c24astcod <> "S60" and
                lr_datmcntsrv.c24astcod <> "S63" and
                lr_datmcntsrv.c24astcod <> "S13" and
                lr_datmcntsrv.c24astcod <> "S47" and
                lr_datmcntsrv.c24astcod <> "S62" and
                lr_datmcntsrv.c24astcod <> "S64" and
                lr_datmcntsrv.c24astcod <> "S23" and
                lr_datmcntsrv.c24astcod <> "S53" and
                lr_datmcntsrv.c24astcod <> "S33" and
                # ASSUNTOS DA AZUL SEGUROS
                lr_datmcntsrv.c24astcod <> "K23" and
                lr_datmcntsrv.c24astcod <> "K33" and
                lr_datmcntsrv.c24astcod <> "K93" and
                lr_datmcntsrv.c24astcod <> "K14" and
                lr_datmcntsrv.c24astcod <> "K33" and
                lr_datmcntsrv.c24astcod <> "K43" then

                let ws.sinvitflg = "N"
                let ws.bocflg    = "N"
                let ws.bocnum    = ""
                let ws.bocemi    = ""
                let ws.vcllibflg = ""
                let ws.roddantxt = ""

                whenever error continue
                execute pbdbsa600027 using ws.atdsrvnum,
                                           ws.atdsrvano,
                                           lr_datmcntsrv.rmcacpflg,
                                           lr_datmcntsrv.vclcamtip,
                                           lr_datmcntsrv.vclcrgflg,
                                           lr_datmcntsrv.vclcrgpso
                whenever error stop

                if sqlca.sqlcode <> 0 then
                   let m_curr = current
                   display "[", m_curr, "] Erro de INSERT na tabela datmservicocmp"
                   rollback work
                   continue foreach
                 end if
             end if

             if lr_datmcntsrv.c24astcod = "S60" or
                lr_datmcntsrv.c24astcod = "S63" or
                lr_datmcntsrv.c24astcod = "S13" or
                lr_datmcntsrv.c24astcod = "S47" or
                lr_datmcntsrv.c24astcod = "S62" or
                lr_datmcntsrv.c24astcod = "S64" then

                # GRAVAR TABELA RE
                whenever error continue
                execute pbdbsa600028 using ws.atdsrvnum,
                                           ws.atdsrvano,
                                           lr_datmcntsrv.socntzcod,
                                           lr_datmcntsrv.atdorgsrvnum,
                                           lr_datmcntsrv.atdorgsrvano
                whenever error stop

                if sqlca.sqlcode <> 0 then
                   let m_curr = current
                   display "[", m_curr, "] Erro de INSERT na tabela datmsrvre"
                   rollback work
                   continue foreach
                end if

             end if

             if lr_datmcntsrv.c24astcod = "S23" or
                lr_datmcntsrv.c24astcod = "S33" or
                lr_datmcntsrv.c24astcod = "S53" or
                # ASSUNTOS DA AZUL SEGUROS
                lr_datmcntsrv.c24astcod = "K14" or
                lr_datmcntsrv.c24astcod = "K23" or
                lr_datmcntsrv.c24astcod = "K33" or
                lr_datmcntsrv.c24astcod = "K43" or
                lr_datmcntsrv.c24astcod = "K53" or
                lr_datmcntsrv.c24astcod = "K93" then
                if lr_datmcntsrv.pasnom1 is not null or
                   lr_datmcntsrv.pasnom2 is not null or
                   lr_datmcntsrv.pasnom3 is not null or
                   lr_datmcntsrv.pasnom4 is not null or
                   lr_datmcntsrv.pasnom5 is not null then
                  # GRAVAR TABELA DE PASSAGEIROS
                   whenever error continue
                   execute pbdbsa600029 using ws.atdsrvnum,
                                              ws.atdsrvano
                   whenever error stop

                   if sqlca.sqlcode <> 0 then
                      let m_curr = current
                      display "[", m_curr, "] Erro de INSERT na tabela datmassistpassag"
                      rollback work
                      continue foreach
                   end if

                     #GRAVAR TABELA DATMPASSAGEIRO
                     #MONTAR ESTA ROTINA PARA 5 OCORRENCIA
                     initialize ws.passeq to null

                     for i = 1 to 5
                       if i = 1 then
                          let lr_datmcntsrv.pasnom1 = lr_datmcntsrv.pasnom1
                          let lr_datmcntsrv.pasida1 = lr_datmcntsrv.pasida1
                       else
                          if i = 2 then
                             let lr_datmcntsrv.pasnom1 = lr_datmcntsrv.pasnom2
                             let lr_datmcntsrv.pasida1 = lr_datmcntsrv.pasida2
                          else
                             if i = 3 then
                                let lr_datmcntsrv.pasnom1 = lr_datmcntsrv.pasnom3
                                let lr_datmcntsrv.pasida1 = lr_datmcntsrv.pasida3
                             else
                                if i = 4 then
                                   let lr_datmcntsrv.pasnom1=lr_datmcntsrv.pasnom4
                                   let lr_datmcntsrv.pasida1=lr_datmcntsrv.pasida4
                                else
                                  if i = 5 then
                                    let lr_datmcntsrv.pasnom1=lr_datmcntsrv.pasnom5
                                    let lr_datmcntsrv.pasida1=lr_datmcntsrv.pasida5
                                  end if
                                end if
                             end if
                          end if
                       end if

                       if lr_datmcntsrv.pasnom1 is null then
                          continue for
                       end if

                       open cbdbsa600030 using ws.atdsrvnum,
                                               ws.atdsrvano
                       whenever error continue
                       fetch cbdbsa600030 into ws.passeq
                       whenever error stop
                       close cbdbsa600030

                       if ws.passeq is null  then
                          let ws.passeq = 0
                       end if

                       let ws.passeq = ws.passeq + 1

                       whenever error continue
                       execute pbdbsa600031 using ws.atdsrvnum,
                                                  ws.atdsrvano,
                                                  ws.passeq,
                                                  lr_datmcntsrv.pasnom1,
                                                  lr_datmcntsrv.pasida1
                       whenever error stop

                       if sqlca.sqlcode  <>  0 then
                          let m_curr = current
                          display "[", m_curr, "] Erro de INSERT na tabela datmpassageiro"
                          rollback work
                          continue foreach
                       end if
                     end for
                end if
             end if

             if lr_datmcntsrv.ocrlgdnom is not null and
                lr_datmcntsrv.ocrlgdnom <> " "      then # ENDERECO OCORRENCIA
                let l_nulo     = null
                let l_num_char = "1"
                let l_zero     = 0
                let l_tres     = 3
                whenever error continue
                execute pbdbsa600032 using ws.atdsrvnum,
                                           ws.atdsrvano,
                                           l_num_char,
                                           l_nulo,
                                           l_nulo,
                                           lr_datmcntsrv.ocrlgdnom,
                                           l_zero,
                                           lr_datmcntsrv.ocrbrrnom,
                                           lr_datmcntsrv.ocrbrrnom,
                                           lr_datmcntsrv.ocrcidnom,
                                           lr_datmcntsrv.ocrufdcod,
                                           lr_datmcntsrv.ocrlclrefptotxt,
                                           lr_datmcntsrv.ocrendzoncod,
                                           l_nulo,
                                           l_nulo,
                                           l_nulo,
                                           l_nulo,
                                           lr_datmcntsrv.ocrlcldddcod,
                                           lr_datmcntsrv.ocrlcltelnum,
                                           lr_datmcntsrv.ocrlclcttnom,
                                           l_zero,                         #L_TRES, RAJI 26/01/2007
                                           l_nulo,
                                           lr_datmcntsrv.ocrendcmp
                whenever error stop

                if sqlca.sqlcode <> 0 then
                   let m_curr = current
                   display "[", m_curr, "] Erro de INSERT na tabela datmlcl - 1"
                   rollback work
                   continue foreach
                end if
             end if

             if lr_datmcntsrv.dstlgdnom is not null and
                lr_datmcntsrv.dstlgdnom <>  " "     then # ENDERECO DESTINO
                let l_nulo     = null
                let l_num_char = "2"
                let l_zero     = 0
                let l_tres     = 3
                whenever error continue
                execute pbdbsa600032 using ws.atdsrvnum,
                                           ws.atdsrvano,
                                           l_num_char,
                                           l_nulo,
                                           l_nulo,
                                           lr_datmcntsrv.dstlgdnom,
                                           l_zero,
                                           lr_datmcntsrv.dstbrrnom,
                                           lr_datmcntsrv.dstbrrnom,
                                           lr_datmcntsrv.dstcidnom,
                                           lr_datmcntsrv.dstufdcod,
                                           l_nulo,
                                           lr_datmcntsrv.dstendzoncod,
                                           l_nulo,
                                           l_nulo,
                                           l_nulo,
                                           l_nulo,
                                           l_nulo,
                                           l_nulo,
                                           l_nulo,
                                           l_zero,  #L_TRES, RAJI 26/01/2007
                                           l_nulo,
                                           l_nulo
                whenever error stop

                if sqlca.sqlcode <> 0 then
                   let m_curr = current
                   display "[", m_curr, "] Erro de INSERT na tabela datmlcl - 2"
                   rollback work
                   continue foreach
                end if
             end if

             # GRAVAR HISTORICO
             let ws.histerr = cts10g02_historico(ws.atdsrvnum    ,
                                    ws.atdsrvano    ,
                                    lr_datmcntsrv.atddat  ,
                                    lr_datmcntsrv.atdhor  ,
                                    lr_datmcntsrv.funmat  ,
                                    "** bdbsa600-CARGA CONTINGENCIA **",
                                    "","","","")

             if l_aux.msg_erro is not null then
                let ws.histerr = cts10g02_historico(ws.atdsrvnum    ,
                                     ws.atdsrvano    ,
                                     lr_datmcntsrv.atddat  ,
                                     lr_datmcntsrv.atdhor  ,
                                     lr_datmcntsrv.funmat  ,
                                     l_aux.msg_erro,
                                     "","","","")
             end if

             if lr_datmcntsrv.obstxt is not null and
                lr_datmcntsrv.obstxt <> " "      then
                let ws.hist1 = lr_datmcntsrv.obstxt[1,50]
                let ws.hist2 = lr_datmcntsrv.obstxt[51,100]
                let ws.hist3 = lr_datmcntsrv.obstxt[101,150]
                let ws.hist4 = lr_datmcntsrv.obstxt[151,200]
                let ws.hist5 = lr_datmcntsrv.obstxt[201,250]

                let ws.histerr = cts10g02_historico
                                 (ws.atdsrvnum    ,
                                  ws.atdsrvano    ,
                                  lr_datmcntsrv.atddat  ,
                                  lr_datmcntsrv.atdhor  ,
                                  lr_datmcntsrv.funmat  ,
                                  ws.hist1,ws.hist2,ws.hist3,
                                  ws.hist4,ws.hist5)
             end if

             # GRAVA ETAPA DO SERVICO
             if ws.atdetpcod <> 1 then  # GERA ETAPA LIBERADO

                # NAO UTILIZAR A FUNCAO PADRAO, POIS ELA INSERE DATA E HORA ATUAL
                # O CORRETO E INSERIR DATA E HORA DA TABELA datmcntsrv
                call bdbsa600_insere_etapa(ws.atdsrvnum,
                                           ws.atdsrvano,
                                           1, # ---> ATDETPCOD
                                           lr_datmcntsrv.atldat,
                                           lr_datmcntsrv.atdhor,
                                           1, # ---> EMPCOD
                                           lr_datmcntsrv.funmat,
                                           "",
                                           "",
                                           "",
                                           "")
                     returning l_ins_etapa

                if l_ins_etapa <> 0 then
                   let m_curr = current
                   display "[", m_curr, "] Erro ao chamar a funcao bdbsa600_insere_etapa() - 4"
                   rollback work
                   continue foreach
                end if
             end if

             # NAO UTILIZAR ESTA A FUNCAO PADRAO, POIS ELA INSERE DATA E HORA ATUAL
             # O CORRETO E INSERIR DATA E HORA DA TABELA datmcntsrv
             call bdbsa600_insere_etapa(ws.atdsrvnum,
                                        ws.atdsrvano,
                                        ws.atdetpcod,
                                        lr_datmcntsrv.atldat,
                                        lr_datmcntsrv.atlhor,
                                        1,  # ---> EMPCOD
                                        lr_datmcntsrv.funmat,
                                        lr_datmcntsrv.atdprscod,
                                        lr_datmcntsrv.srrcoddig,
                                        l_socvclcod,
                                        lr_datmcntsrv.srrabvnom)
                  returning l_ins_etapa

             if l_ins_etapa <> 0 then
                let m_curr = current
                display "[", m_curr, "] Erro ao chamar a funcao bdbsa600_insere_etapa() - 5"
                rollback work
                continue foreach
             end if

             # VERIFICA SE SERVIÇO FOI CANCELADO:
             if lr_datmcntsrv.cnlflg = "S" then
                if lr_datmcntsrv.acndat is  null and   #SERVIÇO NAO ACIONADO
                   lr_datmcntsrv.acnhor is  null then

                   # SERVICO DO IFX NAO ACIONADO NA CONTINGENCIA
                   # FLAG "s" PARA NAO APARECER NO RADIO.
                   whenever error continue
                   execute pbdbsa600023 using ws.atdsrvnum,ws.atdsrvano
                   whenever error stop

                   if sqlca.sqlcode <> 0 then
                      let m_curr = current
                      display "[", m_curr, "] Erro de UPDATE na tabela datmservico - 2"
                      rollback work
                      continue foreach
                   end if
                end if

                # NAO UTILIZAR A FUNCAO PADRAO, POIS ELA INSERE DATA E HORA ATUAL
                # O CORRETO E INSERIR DATA E HORA DA TABELA DATMCNTSRV
                call bdbsa600_insere_etapa(ws.atdsrvnum,
                                           ws.atdsrvano,
                                           5,  # ---> ATDETPCOD
                                           lr_datmcntsrv.atldat,
                                           lr_datmcntsrv.atlhor,
                                           1,  # ---> EMPCOD
                                           lr_datmcntsrv.funmat,
                                           lr_datmcntsrv.atdprscod,
                                           lr_datmcntsrv.srrcoddig,
                                           l_socvclcod,
                                           lr_datmcntsrv.srrabvnom)
                     returning l_ins_etapa

                if l_ins_etapa <> 0 then
                   let m_curr = current
                   display "[", m_curr, "] Erro ao chamar a funcao bdbsa600_insere_etapa() - 6"
                   rollback work
                   continue foreach
                end if
             end if
             whenever error continue

             # ATUALIZA "S" NO CAMPO PRCFLG
             execute pbdbsa600033 using ws.atdsrvnum,
                                        ws.atdsrvano,
                                        lr_datmcntsrv.seqreg
             whenever error stop

             if sqlca.sqlcode <> 0 then
                let m_curr = current
                display "[", m_curr, "] Erro de UPDATE na tabela datmcntsrv"
                rollback work
                continue foreach
             end if

             let lr_datmcntsrv.atdsrvnum = ws.atdsrvnum
             let lr_datmcntsrv.atdsrvano = ws.atdsrvano
          end if

          commit work

          # PONTO DE ACESSO APOS A GRAVACAO DO LAUDO
          call cts00g07_apos_grvlaudo(lr_datmcntsrv.atdsrvnum,
                                      lr_datmcntsrv.atdsrvano)

          call ctx28g00("bdbsa600", fgl_getenv("SERVIDOR"), m_tmpexp)
               returning m_tmpexp, m_prcstt

       end foreach

       close cbdbsa600001

       # FUNCAO RESPONSAVEL POR EXECUTAR A ATUALIZACAO DA FROTA (2º PROCESSO)
       begin work

       let l_processo_ok = bdbsa600_2_processo(l_socvclcod)

       if l_processo_ok = false then
          rollback work
       else
          commit work
       end if

       call ctx28g00("bdbsa600", fgl_getenv("SERVIDOR"), m_tmpexp)
               returning m_tmpexp, m_prcstt

       # FUNCAO RESPONSAVEL POR EXECUTAR A ATUALIZACAO DAS MENSAGENS E LOGS (3º e 4º PROCESSO)
       call bdbsa600_3e4_processo()

       call ctx28g00("bdbsa600", fgl_getenv("SERVIDOR"), m_tmpexp)
               returning m_tmpexp, m_prcstt

       call bdbsa600_envia_mail()

   else
       let m_curr = current
       display "[", m_curr, "] CONTINGENCIA ATIVA"
   end if

 end function

#---------------------------------------#
 function bdbsa600_2_processo(l_socvclcod)
#---------------------------------------#

  define l_socvclcod like datkveiculo.socvclcod

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
         l_sqlcode        integer

  # ---FUNCAO RESPONSAVEL POR EXECUTAR O SEGUNDO PROCESSO DA CARGA
  # ---DA CONTINGENCIA, QUE E A ATUALIZACAO DA FROTA

  open cbdbsa600010
  foreach cbdbsa600010 into lr_datmcntsttvcl.seqreg,
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


     open cbdbsa600002 using lr_datmcntsttvcl.atdvclsgl
     fetch cbdbsa600002 into l_socvclcod

     if sqlca.sqlcode <> 0 then
        let l_socvclcod = null
     end if

     close cbdbsa600002

     #-----------------------------------
     # VERIFICA ONDE O SERVICO FOI GERADO
     #-----------------------------------
     if lr_datmcntsttvcl.seqregcnt is not null then
        # SERVICO GERADO NA CONTINGENCIA BUSCA ATDSRVNUM E ATDSRVANO DA TABELA DATMCNTSRV
        open cbdbsa600009 using lr_datmcntsttvcl.seqregcnt
        fetch cbdbsa600009 into lr_datmcntsttvcl.atdsrvnum,
                                lr_datmcntsttvcl.atdsrvano
        close cbdbsa600009
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

     #-----------------------------------------
     # VERIFICA SE ATUALIZA A TABELA DATMFRTPOS
     #-----------------------------------------
     if lr_datmcntsttvcl.qtilclltt is not null and
        lr_datmcntsttvcl.qtilclltt <> " "      then

        whenever error continue
        execute pbdbsa600011 using lr_datmcntsttvcl.qtiufdcod,
                                   lr_datmcntsttvcl.qticidnom,
                                   lr_datmcntsttvcl.qtibrrnom,
                                   lr_datmcntsttvcl.qtiendzon,
                                   lr_datmcntsttvcl.qtilclltt,
                                   lr_datmcntsttvcl.qtilcllgt,
                                   l_socvclcod
        whenever error stop

         if sqlca.sqlcode <> 0 then
            let m_curr = current
            display "[", m_curr, "] Erro de UPDATE na tabela datmfrtpos"
            continue foreach
         end if
     end if

     initialize lr_datmcntsttvcl to null

  end foreach
  close cbdbsa600010

  # -> EXCLUI OS DADOS DA TABELA DATMCNTSTTVCL
  whenever error continue
  execute pbdbsa600050
  whenever error stop

  if sqlca.sqlcode <> 0 then
     let m_curr = current
     display "[", m_curr, "] Erro de DELETE na tabela datmcntsttvcl"
  end if

  return l_processo_ok

end function


#--------------------------------#
 function bdbsa600_3e4_processo()
#--------------------------------#

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

  define l_mdtmsgnumifx   like datmcntmsgctr.mdtmsgnum,
         l_processo_ok    smallint,
         l_max_mdtlogseq  integer



  # ACESSA TODOS O REGISTROS DA TABELA datmcntmsgctr COM prcflg = 'N'
  open cbdbsa600012
  foreach cbdbsa600012 into lr_datmcntmsgctr.mdtmsgnum,
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

     if lr_datmcntmsgctr.novmsgflg = "S" then
        #----------------------------
        # INSERE NA TABELA datmmdtmsg
        #----------------------------
        #CT: 80311643
        begin work
        whenever error continue
        execute pbdbsa600013 using lr_datmcntmsgctr.mdtmsgorgcod,
                                   lr_datmcntmsgctr.mdtcod,
                                   lr_datmcntmsgctr.mdtmsgstt,
                                   lr_datmcntmsgctr.mdtmsgavstip

        let l_mdtmsgnumifx = sqlca.sqlerrd[2]
        whenever error stop

        if sqlca.sqlcode <> 0 then
           let m_curr = current
           display "[", m_curr, "] Erro de INSERT na tabela datmmdtmsg"
           execute pbdbsa600051 using lr_datmcntmsgctr.mdtmsgnum
           rollback work
           continue foreach
        else
           commit work
        end if

        #-------------------------------
        # INSERE NA TABELA datmmdtmsgtxt
        #-------------------------------

        begin work
        whenever error continue
        execute pbdbsa600014 using l_mdtmsgnumifx,
                                   lr_datmcntmsgctr.mdtmsgtxtseq,
                                   lr_datmcntmsgctr.mdtmsgtxt
        whenever error stop

        if sqlca.sqlcode <> 0 then
           let m_curr = current
           display "[", m_curr, "] Erro de INSERT na tabela datmmdtmsgtxt"
           execute pbdbsa600051 using lr_datmcntmsgctr.mdtmsgnum
           rollback work
           continue foreach
        else
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
           open cbdbsa600009 using lr_datmcntmsgctr.seqregcnt
           fetch cbdbsa600009 into lr_datmcntmsgctr.atdsrvnum,
                                   lr_datmcntmsgctr.atdsrvano
           close cbdbsa600009
        end if

        #----------------------------
        # INSERE NA TABELA datmmdtsrv
        #----------------------------
        #CT: 80311643
        begin work
        whenever error continue
        execute pbdbsa600015 using l_mdtmsgnumifx,
                                   lr_datmcntmsgctr.atdsrvnum,
                                   lr_datmcntmsgctr.atdsrvano
        whenever error stop

        if sqlca.sqlcode <> 0 then
           let m_curr = current
           display "[", m_curr, "] Erro de INSERT na tabela datmmdtsrv"
           execute pbdbsa600051 using lr_datmcntmsgctr.mdtmsgnum
           rollback work
           continue foreach
        else
           commit work
        end if

     else
        #-----------------------------
        # ATUALIZA A TABELA datmmdtmsg
        #-----------------------------
        #CT: 80311643
        begin work
        whenever error continue
        execute pbdbsa600019 using lr_datmcntmsgctr.mdtmsgstt,
                                   lr_datmcntmsgctr.mdtmsgnum
        whenever error stop

        if sqlca.sqlcode <> 0 then
           let m_curr = current
           display "[", m_curr, "] Erro de UPDATE na tabela datmmdtmsg"
           execute pbdbsa600051 using lr_datmcntmsgctr.mdtmsgnum
           continue foreach
        else
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
     begin work
     whenever error continue
     execute pbdbsa600021 using lr_datmcntmsgctr.mdtmsgnum
     whenever error stop
     if sqlca.sqlcode <> 0 then
        let m_curr = current
        display "[", m_curr, "] Erro de UPDATE na tabela datmcntmsgctr"
        execute pbdbsa600051 using lr_datmcntmsgctr.mdtmsgnum
        rollback work
        continue foreach
     else
        commit work
     end if

     initialize lr_datmcntmsgctr, lr_datmcntlogctr to null
  # ATUALIZA DATMCNTMSGCTR.PRCFLG = s WHERE MDTMSGNUM=LR_DATMCNTMSGCTR.MDTMSGNUM
  end foreach
  close cbdbsa600012

  #------------------------------------------------------------------
  # ACESSA TODOS OS REGISTROS DA TABELA DATMCNTLOGCTR COM PRCFLG = 'N'
  # ACESSA TODOS OS REGISTROS DAS TABELAS DATMCNTLOGCTR E DATMCNTMSGCTR
  #----------------------------------------------------------------------
  open cbdbsa600016
  foreach cbdbsa600016 into lr_datmcntlogctr.mdtmsgnum,
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
                            # BUSCAR TODOS COM DATMCNTLOGCTR.PRCFLG="N"


     #---------------------------------------------
     # BUSCA A MAIOR MDTLOGSEQ DA TABELA DATMMDTLOG
     #---------------------------------------------
     if lr_datmcntmsgctr.atdsrvnum  is not null then
        if lr_datmcntmsgctr.novmsgflg = "S" or
           lr_datmcntmsgctr.novmsgflg is null then

           # BUSCA ULTIMA MENSAGEM DO SERVICO datmmdtsrv
           open cbdbsa600044 using lr_datmcntmsgctr.atdsrvnum,
                                   lr_datmcntmsgctr.atdsrvano
           fetch cbdbsa600044 into l_mdtmsgnumifx
           close cbdbsa600044
        else
           let l_mdtmsgnumifx = lr_datmcntlogctr.mdtmsgnum
        end if
     else
        # BUSCA ATDSRVNUM E ATDSRVANO DA TABELA DATMCNTSRV
        open cbdbsa600009 using lr_datmcntmsgctr.seqregcnt
        fetch cbdbsa600009 into lr_datmcntmsgctr.atdsrvnum,
                                lr_datmcntmsgctr.atdsrvano
        close cbdbsa600009
        # BUSCA ULTIMA MENSAGEM DO SERVICO DATMMDTSRV
        open cbdbsa600044 using lr_datmcntmsgctr.atdsrvnum,
                                lr_datmcntmsgctr.atdsrvano
        fetch cbdbsa600044 into l_mdtmsgnumifx
        close cbdbsa600044

     end if

     # BUSCA ULTIMA SEQUENCIA DA TABELA DATMMDTLOG
     open cbdbsa600017 using l_mdtmsgnumifx
     fetch cbdbsa600017 into l_max_mdtlogseq
     close cbdbsa600017

     if l_max_mdtlogseq is null then
        let l_max_mdtlogseq = 0
     end if

     let l_max_mdtlogseq = (l_max_mdtlogseq + 1)

     #----------------------------
     # INSERE NA TABELA DATMMDTLOG
     #----------------------------

     begin work
     whenever error continue
     execute pbdbsa600018 using l_mdtmsgnumifx,
                                l_max_mdtlogseq,
                                lr_datmcntlogctr.mdtmsgstt,
                                lr_datmcntlogctr.atldat,
                                lr_datmcntlogctr.atlhor,
                                lr_datmcntlogctr.atlemp,
                                lr_datmcntlogctr.atlmat,
                                lr_datmcntlogctr.atlusrtip
     whenever error stop

     if sqlca.sqlcode <> 0 then
        let m_curr = current
        display "[", m_curr, "] Erro de INSERT na tabela datmmdtlog"
        rollback work
        continue foreach
     else
        commit work
     end if

     #-----------------------------
     # ATUALIZA A TABELA datmmdtmsg
     #-----------------------------
     #CT: 80311643
     begin work
     whenever error continue
     execute pbdbsa600019 using lr_datmcntlogctr.mdtmsgstt,
                                l_mdtmsgnumifx
     whenever error stop

     if sqlca.sqlcode <> 0 then
        let m_curr = current
        display "[", m_curr, "] Erro de UPDATE na tabela datmmdtmsg"
        rollback work
        continue foreach
     else
        commit work
     end if

     #-----------------------------------------------
     # ATUALIZA A TABELA DATMCNTLOGCTR PRCFLG = "S"
     #-----------------------------------------------
     begin work
     whenever error continue
     execute pbdbsa600043 using lr_datmcntlogctr.mdtmsgnum
     whenever error stop

     if sqlca.sqlcode <> 0 then
        let m_curr = current
        display "[", m_curr, "] Erro de UPDATE na tabela datmcntlogctr"
        rollback work
        continue foreach
     else
        commit work
     end if

     initialize lr_datmcntlogctr to null

  end foreach
  close cbdbsa600016

end function

#-------------------------------#
function bdbsa600_cgccpf(l_param)
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
    let l_aux.msg_erro = "bdbsa600-Digito do CGC/CPF incorreto!"
    return l_aux.msg_erro
 end if

 ### PSI 202720
 if l_param.ramgrpcod = 5 then ## Saude
    call cta01m15_sel_datksegsau(6, "","",l_param.cgccpfnum, l_param.cpfdig)
         returning m_status, m_msg, m_crtsaunum, m_bnfnum

    if m_status <> 1 then
       let l_aux.msg_erro = "bdbsa600-Segurado não encontrado-cpfSaude"
    else
       let g_documento.crtsaunum = m_crtsaunum
       let g_documento.bnfnum    = m_bnfnum

       # BUSCA NUMERO DO CARTAO P/ GRAVAR DATRSRVSAU
       open cbdbsa600053 using g_documento.crtsaunum
       whenever error continue
       fetch cbdbsa600053 into m_succod,
                               m_ramcod,
                               m_aplnumdig
       whenever error stop
       close cbdbsa600053
    end if

    return l_aux.msg_erro

 end if

 open cbdbsa600034 using  l_param.cgccpfnum, l_aux.pestip
 foreach cbdbsa600034 into l_aux.segnumdig

    if l_param.ramcod = 31 or
       l_param.ramcod = 531 then

      open cbdbsa600035 using l_aux.segnumdig, l_aux.segnumdig
      foreach cbdbsa600035 into l_aux.succod, l_aux.aplnumdig

         open cbdbsa600036 using l_aux.succod, l_aux.aplnumdig
         whenever error continue
         fetch cbdbsa600036 into l_aux.aplstt, l_aux.viginc, l_aux.vigfnl
         whenever error stop
         close cbdbsa600036

         if l_aux.aplstt = "C" or       # apolice cancelada
            l_aux.vigfnl < today then  # apolice vencida
            let m_curr = current
            display "[", m_curr, "] APOLICE VENCIDA"
            continue foreach
         end if

         #ACESSAR TODOS OS ITENS DA APOLICE
         open cbdbsa600037 using l_aux.succod, l_aux.aplnumdig
         foreach cbdbsa600037 into l_aux.itmnumdig

            # STATUS DO ITEM
            open cbdbsa600038 using l_aux.succod,l_aux.aplnumdig,l_aux.itmnumdig
            whenever error continue
            fetch cbdbsa600038 into l_aux.itmsttatu
            whenever error stop
            close cbdbsa600038

            if l_aux.itmsttatu = "A" then
               initialize   l_aux.msg_erro to null
               let g_documento.succod    = l_aux.succod
               let g_documento.ramcod    = l_param.ramcod
               let g_documento.aplnumdig = l_aux.aplnumdig
               let g_documento.itmnumdig = l_aux.itmnumdig
               return l_aux.msg_erro
            end if

         end foreach
         close cbdbsa600037

      end foreach
      close cbdbsa600035

   else

       open cbdbsa600039 using l_aux.segnumdig
       foreach cbdbsa600039 into l_aux.prporg
                           ,l_aux.prpnumdig
                           ,l_aux.sgrorg
                           ,l_aux.sgrnumdig
                           ,l_aux.dctnumseq
                           ,l_aux.succod
                           ,l_aux.aplnumdig
                           ,l_aux.ramcod

           # VERIFICA SE APOLICE ESTA ATIVA
           open cbdbsa600022 using l_aux.prporg,
                                   l_aux.prpnumdig
           fetch cbdbsa600022 into l_aux.vigfnl
           close cbdbsa600022

           if l_aux.vigfnl > today then   # APOLICE ATIVA
              initialize l_aux.msg_erro to null
              let g_documento.succod    = l_aux.succod
              let g_documento.ramcod    = l_aux.ramcod
              let g_documento.aplnumdig = l_aux.aplnumdig
              let g_documento.itmnumdig = 0
              return l_aux.msg_erro
           end if

       end foreach
       close cbdbsa600039

    end if

 end foreach
 close cbdbsa600034

 if l_aux.aplnumdig is null then
    let l_aux.msg_erro = "bdbsa600-Apolice não encontrados-cpf"
 end if

 return l_aux.msg_erro

end function

#------------------------------------------#
function bdbsa600_insere_etapa(lr_parametro)
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
  let   l_sttetp     =  null

  let l_status    = 0
  let l_sttetp    = 0
  let l_atdsrvseq = null

  # -> BUSCA A ULTIMA SEQUENCIA DO SERVICO
  open cbdbsa600049 using lr_parametro.atdsrvnum, lr_parametro.atdsrvano
  fetch cbdbsa600049 into l_atdsrvseq
  close cbdbsa600049

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
  execute pbdbsa600048 using lr_parametro.atdsrvnum,
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

#------------------------------#
function bdbsa600_placa(l_param)
#------------------------------#

 # CARGA DA CONTINGENCIA POR PLACA.
 # FUNÇÃO PESQUISA APOLICE POR PLACA:

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

    open cbdbsa600040 using l_param.vcllicnum
    foreach cbdbsa600040  into l_aux.succod
                             ,l_aux.aplnumdig
                             ,l_aux.itmnumdig
                             ,l_aux.dctnumseq

       call F_FUNAPOL_ULTIMA_SITUACAO(l_aux.succod
                                     ,l_aux.aplnumdig
                                     ,l_aux.itmnumdig)
          returning g_funapol.*

       if g_funapol.resultado = "O" then

          open cbdbsa600036 using l_aux.succod, l_aux.aplnumdig
          whenever error continue
          fetch cbdbsa600036 into l_aux.aplstt, l_aux.viginc, l_aux.vigfnl
          whenever error stop
          close cbdbsa600036

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
    close cbdbsa600040

  end if

  if l_aux.achou = 1 then
     let l_aux.msg_erro = "bdbsa600-Apolice nao encontrada-placa"
  end if

  return l_aux.msg_erro

end function

#--------------------------------#
function bdbsa600_apolice(l_param)
#--------------------------------#

 # FUNÇÃO VALIDAR APOLICE
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

 --[ validar sucursal
 call f_fungeral_sucursal(l_param.succod)
      returning l_aux.sucnom

 if l_aux.sucnom is null then
    let l_aux.msg_erro = "bdbsa600-Sucursal nao cadastrada"
    return l_aux.msg_erro
 end if

 initialize l_aux.aplnumdig to null
 call F_FUNDIGIT_DIGAPOL(l_param.succod
                        ,l_param.ramcod
                        ,l_aux.apl)
      returning l_aux.aplnumdig

 if l_aux.aplnumdig is null  then
    let l_aux.msg_erro = "bdbsa600-Apolice não encontrada"
    return l_aux.msg_erro
 end if

 if l_aux.aplnumdig <>     l_param.aplnumdig then
    let l_aux.msg_erro = "bdbsa600-Problemas com digito da Apolice"
    return l_aux.msg_erro
 end if

 # OBTER DADOS DA APOLICE DE AUTO
 if l_param.ramcod = 31 or
    l_param.ramcod = 531 then
    call cty05g00_dados_apolice(l_param.succod
                               ,l_param.aplnumdig)
         returning lr_cty05g00.*

    if lr_cty05g00.resultado = 2 or
       lr_cty05g00.resultado = 3 or
       lr_cty05g00.emsdat is null then
       let l_aux.msg_erro = "bdbsa600-",lr_cty05g00.mensagem
       return l_aux.msg_erro
    end if

    if lr_cty05g00.emsdat is null then
       let l_aux.msg_erro = "bdbsa600-",lr_cty05g00.mensagem
       return l_aux.msg_erro
    end if

    if lr_cty05g00.vigfnl < today  then
       let l_aux.msg_erro = "bdbsa600-Apolice Vencida"
       return l_aux.msg_erro
    end if

    if lr_cty05g00.aplstt = "C" then
       let l_aux.msg_erro = "bdbsa600-Apolice Cancelada"
       return l_aux.msg_erro
    end if

    # VALIDA ITEM DA APOLICE
    call F_FUNDIGIT_DIGITO11 (l_param.itmnumdig)
         returning l_aux.itmnumdig

    if l_aux.itmnumdig  is null   then
       let l_aux.msg_erro = "bdbsa600-Problemas no digito do item"
       return l_aux.msg_erro
    end if

    # CONSISTIR O ITEM NA APOLICE
    call cty05g00_consiste_item(l_param.succod
                               ,l_param.aplnumdig
                               ,l_param.itmnumdig)
         returning l_aux.flag

    if l_aux.flag = 2 then
       let l_aux.msg_erro = "bdbsa600-Item nao existe nesta apolice"
       return l_aux.msg_erro
    end if

    # OBTER ULTIMA SITUACAO DA APOLICE DE AUTO
    call f_funapol_ultima_situacao(l_param.succod
                                  ,l_param.aplnumdig
                                  ,l_param.itmnumdig)

         returning  g_funapol.*

    if g_funapol.resultado <> "O"   then
       let l_aux.msg_erro = "bdbsa600-Ultima situacao da apl nao encontrada"
       return l_aux.msg_erro
    end if

 else
    # OBTER DADOS APOLICE RE
    call cty06g00_dados_apolice(l_param.succod
                               ,l_param.ramcod
                               ,l_param.aplnumdig
                               ,l_aux.ramsgl)
         returning lr_cty06g00.*

    if lr_cty06g00.resultado = 2 or
       lr_cty06g00.resultado = 3 then
       let l_aux.msg_erro = "bdbsa600-",lr_cty06g00.mensagem
       return l_aux.msg_erro
    end if

    if lr_cty06g00.aplstt is null then
       let l_aux.msg_erro = "bdbsa600-Apolice de RE nao cadastrada "
       return l_aux.msg_erro
    end if
 end if

  let g_documento.succod    = l_param.succod
  let g_documento.ramcod    = l_param.ramcod
  let g_documento.aplnumdig = l_param.aplnumdig
  let g_documento.itmnumdig = l_param.itmnumdig

  return l_aux.msg_erro

end function

#-------------------------------#
function bdbsa600_nome(l_param)
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

  declare c_crtsaunum cursor for
     select crtsaunum,bnfnum,crtstt
        from datksegsau
       where segnom = l_param.nome
  let l_aux.achou = 1
  foreach c_crtsaunum into g_documento.crtsaunum,
                           g_documento.bnfnum,
                           l_aux.crtstt
     if l_aux.crtstt = "A" then
        let l_aux.achou = 0
        exit foreach
     end if
  end foreach

  if l_aux.achou   =  1 then
     let l_aux.msg_erro = "bdbsa600-Cartao nao encontrado-nome"
  else
     let l_aux.msg_erro = null
  end if

  return l_aux.msg_erro

end function

#------------------------------#
 function bdbsa600_envia_mail()
#------------------------------#

     define lr_cnt record
        psccntcod like datkcnthst.psccntcod,
        fnldat    like datkcnthst.fnldat,
        inidat    like datkcnthst.inidat
     end record

     define lr_mail record
         rem char(50),
         des char(250),
         ccp char(250),
         cco char(250),
         ass char(150),
         msg char(32000),
         idr char(20),
         tip char(4)
     end record

     define l_cod_erro  integer,
            l_msg_erro  char(20),
            l_count     smallint,
            l_c24astcod like datmligacao.c24astcod,
            l_c24astdes like datkassunto.c24astdes,
            l_aux       smallint,
            l_datini    char(10),
            l_datfim    char(10),
            l_horini    char(05),
            l_horfim    char(05),
            l_total     integer,
            l_totalctg  integer,
            l_totalifx  integer,
            l_sem       integer,
            l_com       integer,
            l_ret       char(15),
            l_pen       integer,
            l_atdsrvnum like datmservico.atdsrvnum,
            l_atdsrvano like datmservico.atdsrvano


     initialize lr_mail.*,
                lr_cnt.* to null

     open cbdbsa600042
     fetch cbdbsa600042 into lr_cnt.psccntcod,
                             lr_cnt.fnldat,
                             lr_cnt.inidat

         if  lr_cnt.psccntcod is not null and lr_cnt.psccntcod <> " " then
            open cbdbsa600067 using lr_cnt.psccntcod
         fetch cbdbsa600067 into l_pen

         if  l_pen = 0 then

            execute pbdbsa600054

             open cbdbsa600065 using lr_cnt.psccntcod
             fetch cbdbsa600065 into l_total

             open cbdbsa600063 using lr_cnt.psccntcod
             fetch cbdbsa600063 into l_totalifx

             open cbdbsa600064 using lr_cnt.psccntcod
             fetch cbdbsa600064 into l_totalctg

             open cbdbsa600066 using lr_cnt.psccntcod,
                                     lr_cnt.psccntcod

             let l_sem = 0
             let l_com = 0

             foreach cbdbsa600066 into l_atdsrvnum,
                                       l_atdsrvano

                 let l_ret = cts20g11_identifica_tpdocto(l_atdsrvnum,
                                                         l_atdsrvano)

                 if  l_ret = "SEMDOCTO" then
                     let l_sem = l_sem + 1
                 else
                     let l_com = l_com + 1
                 end if

             end foreach

             let lr_mail.des = "sergio.burini@correioporto"
             let lr_mail.rem = "porto.socorro@portoseguro.com.br"
             let lr_mail.ccp = ""
             let lr_mail.cco = ""
             let lr_mail.ass = "FINALIZACAO NO PROCESSO CARGA CONTINGENCIA"
             let lr_mail.idr = "F0104577"
             let lr_mail.tip = "html"

             let lr_mail.msg = "<html>",
                                  "<body>",
                                     "<font face=arial size=2>",
                                     "<table border=0 cellspacing=0 cellpadding=2 width=80% bgcolor=#1B70E1 align=center>",
                                     "<tr>",
                                         "<td><font size=2 color=white face=arial><b><center>",
                                         "Relatorio Carga da Contingencia</b></font></center></td>",
                                     "</tr>",
                                     "</table>",
                                     "<br>",

                                     "<table>",
                                         "<tr>",
                                             "<td colspan='5' bgcolor=#1B70E1>",
                                                 "<font size=2 color=white face=arial><b><center>Dados do processamento</td>",
                                         "</tr>",
                                         "<tr bgcolor=#E2E9F1>",
                                             "<td colspan='2'><center><font face=arial size=2 color=#1B70E1><b>Codigo da Contingencia</td>",
                                             "<td colspan='2'><center><font face=arial size=2 color=#1B70E1><b>Data Inicial</td>",
                                             "<td width=33%><center><font face=arial size=2 color=#1B70E1><b>Data Final</td>",
                                         "</tr>",
                                         "<tr bgcolor=#E2E9F1>",
                                             "<td colspan='2'><center><font face=arial size=2><b>", lr_cnt.psccntcod ,"</td>",
                                             "<td colspan='2'><center><font face=arial size=2><b>", extend(lr_cnt.inidat,day to day),"/",
                                                                                                    extend(lr_cnt.inidat,month to month), "/",
                                                                                                    extend(lr_cnt.inidat,year to year)," ",
                                                                                                    extend(lr_cnt.inidat,hour to hour),":",
                                                                                                    extend(lr_cnt.inidat,minute to minute), ":",
                                                                                                    extend(lr_cnt.inidat,second to second),"</td>",
                                             "<td><center><font face=arial size=2><b>", extend(lr_cnt.fnldat,day to day),"/",
                                                                                        extend(lr_cnt.fnldat,month to month), "/",
                                                                                        extend(lr_cnt.fnldat,year to year)," ",
                                                                                        extend(lr_cnt.fnldat,hour to hour),":",
                                                                                        extend(lr_cnt.fnldat,minute to minute), ":",
                                                                                        extend(lr_cnt.fnldat,second to second),"</td>",
                                         "</tr>",
                                         "<tr bgcolor=#E2E9F1>",
                                             "<td><center><font face=arial size=2 color=#1B70E1><b>Tot. SRVs lidos.</td>",
                                             "<td><center><font face=arial size=2 color=#1B70E1><b>SRVs Informix</td>",
                                             "<td><center><font face=arial size=2 color=#1B70E1><b>SRVs Contingencia</td>",
                                             "<td><center><font face=arial size=2 color=#1B70E1><b>Com DOC.</td>",
                                             "<td><center><font face=arial size=2 color=#1B70E1><b>Sem DOC.</td>",
                                         "</tr>",
                                         "<tr bgcolor=#E2E9F1>",
                                             "<td><center><font face=arial size=2><b>", l_total, "</td>",
                                             "<td><center><font face=arial size=2><b>", l_totalifx, "</td>",
                                             "<td><center><font face=arial size=2><b>", l_totalctg, "</td>",
                                             "<td><center><font face=arial size=2><b>", l_com, "</td>",
                                             "<td><center><font face=arial size=2><b>", l_sem, "</td>",
                                         "</tr>",
                                     "</table>",



                                     "<br>",
                                     "<table width=80%>",
                                         "<tr bgcolor=#1B70E1>",
                                             "<td><font size=2 color=white face=arial><b>Assunto</td>",
                                             "<td><font size=2 color=white face=arial><b><center>Quantidade</td>",
                                         "</tr>"

              open cbdbsa600060 using lr_cnt.psccntcod

              let l_aux = 1
              let l_total = 0

              foreach cbdbsa600060 into l_count, l_c24astcod

                  open cbdbsa600061 using l_c24astcod
                  fetch cbdbsa600061 into l_c24astdes

                  if  (l_aux mod 2) <> 0 then
                      let lr_mail.msg = lr_mail.msg clipped, "<tr bgcolor=#E2E9F1>"
                  else
                      let lr_mail.msg = lr_mail.msg clipped, "<tr bgcolor=#B9D3EE>"
                  end if

                      let lr_mail.msg = lr_mail.msg clipped,"<td><font face=arial size=1><b>",l_c24astcod clipped,"</b> - ", l_c24astdes clipped ,"</td>",
                                                            "<td><font face=arial size=1><center>",l_count,"</td>",
                                                        "</tr>"
                  let l_aux = l_aux + 1
                  let l_total = l_total + l_count

              end foreach

              let lr_mail.msg = lr_mail.msg clipped, "<tr>",
                                                          "<td align=right><font face=arial size=1>Total de Servicos: </td>",
                                                          "<td><center><b><font face=arial size=1>", l_total, "</td>",
                                                     "</tr>",
                                                 "</table>",
                                             "</body>",
                                         "</html>"

             display lr_mail.msg clipped

             call figrc009_mail_send1(lr_mail.*)
                  returning l_cod_erro, l_msg_erro

             if  l_cod_erro <> 0 then
                 display "Erro no envio do email: ",
                         l_cod_erro using "<<<<<<&", " - ",
                         l_msg_erro clipped
             else
                let m_curr = current
                display "[", m_curr, "] EMAIL ENVIADO: ", l_cod_erro, l_msg_erro
                execute pbdbsa600045 using lr_cnt.psccntcod
             end if
         end if
     end if

 end function
