#############################################################################
# Nome do Modulo: CTA02M02                                         Pedro    #
#                                                                  Marcelo  #
# Mostra todas as ligacoes/servicos                                Dez/1994 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 15/10/1998  PSI 6895-0   Gilberto     Permitir registrar RETORNOS para    #
#                                       servicos atraves do codigo RET.     #
#---------------------------------------------------------------------------#
# 28/04/1999  PSI 7547-7   Gilberto     Substituicao da situacao pela ulti- #
#                                       ma etapa do servico.                #
#---------------------------------------------------------------------------#
# 21/10/1999  PSI 9118-9   Gilberto     Alterar funcao de gravacao da liga- #
#                                       cao (CTS10G00) para gravar as tabe- #
#                                       las de relacionamento.              #
#---------------------------------------------------------------------------#
# 08/12/1999  PSI 7263-0   Gilberto     Exibir historico de ligacoes para   #
#                                       propostas.                          #
#---------------------------------------------------------------------------#
# 02/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de      #
#                                       solicitante.                        #
#---------------------------------------------------------------------------#
# 27/03/2000  PSI 10079-0  Akio         Atendimento da perda parcial        #
#---------------------------------------------------------------------------#
# 03/05/2000  Sofia        Akio         Inclusao de identificador de regis- #
#                                       tro de pendencia para assunto U10   #
#---------------------------------------------------------------------------#
# 05/07/2000  PSI 10865-0  Akio         Substituicao do atdtip p/ atdsrvorg #
#                                       Exibicao do atdsrvnum (dec 10,0)    #
#---------------------------------------------------------------------------#
# 24/08/2000  Arnaldo      Ruiz         aumento do array de 100 p/ 200      #
#---------------------------------------------------------------------------#
# 06/02/2001  PSI 12479-6  Ruiz         Marcacao de vistorias em postos     #
#                                       (agendamento).                      #
#---------------------------------------------------------------------------#
# 03/04/2001  PSI 12755-8  Raji         Ligacoes atendidas na proposta      #
#---------------------------------------------------------------------------#
# 25/04/2001  PSI 12768-0  Wagner       Display do nr;servico para reclama- #
#                                       coes Wxx.                           #
#---------------------------------------------------------------------------#
# 28/05/2001  PSI 13042-7  Ruiz         mostrar prestador qdo for servico de#
#                                       vidros.                             #
#---------------------------------------------------------------------------#
# 18/02/2002  PSI 13132-2  Ruiz         Liberar tecla F8 para counsulta aos #
#                                       sinistros.                          #
#############################################################################
#                                                                           #
#                       * * * Alteracoes * * *                              #
#                                                                           #
# Data        Autor Fabrica  Origem      Alteracao                          #
# ----------  -------------- --------- -----------------------------------  #
# 18/09/2003  Meta,Bruno     PSI175552 Passar paramentro na funcao cst16m01.#
#                            OSF26077                                       #
#                                                                           #
# 27/10/2003  Meta,Alexson   PSI172413 Foram feitas novas consistencias para#
#                            OSF027987 os campos CORSUS,CGC/CPF,FUNMAT E    #
#                                      CTTTEL.                              #
# 20/11/2003  Meta,Ivone     PSI172057 Mostrar todas a ligacoes da apolice  #
#                            OSF028991                                      #
#                                                                           #
# 27/11/2003  Meta, Ivone       PSI172111  Incluir parametro ultima ligacao #
#                               OSF 29343  consultada na funcao             #
#                                           cts20g00_ligacao()              #
#                                                                           #
# 17/12/2003  Meta, Robson   PSI180475 Aumentar o tamanho do campo no form  #
#                            OSF030228 cta02m02. Incluir uma opcao de menu  #
#                                      e alterar opcao ja existente. Seleci-#
#                                      onar a opcao (F6) motivo.            #
#                                      Apresentar as ligacoes que possuem   #
#                                      motivos cadastrados, com asterisco na#
#                                      frente do assunto.                   #
#                                                                           #
# 04/06/2004  Marcio (FSFW)  CT-210587 adicionar if na clausula else do pgm #
#                                                                           #
# 20/09/2004  Marcio Meta    PSI187550 Incluir a chamada da funcao          #
#                                      cts20g14_motivo_con() e a funcao     #
#                                      cts20g14_desc_motivo().              #
# 25/10/2004  Meta, James    PSI188514 Acrescentar tipo de solicitacao = 8  #
#                                                                           #
# 28/02/2005  Robson - Meta  PSI190772 Funcoes cta02m02_pesquisar_ligacoes, #
#                                      cta02m02_obter_ligacoes,             #
#                                      cta02m02_ligacoes_propostas e funcao #
#                                      cta02m02 remodelada em               #
#                                      cta02m02_consultar_ligacoes          #
#                                                                           #
# 23/03/2005  James, Meta    PSI191094 Chamar a funcao cta00m06 e tratar o  #
#                                      retorno na mensagem e no f6 e f9     #
#---------------------------------------------------------------------------#
# 08/02/2006  Priscila       Zeladoria Buscar data e hora do banco de dados #
#---------------------------------------------------------------------------#
# 14/11/2006  Ruiz           psi205206 Ajustes p/ atd. Azul Seguros         #
# 09/04/2008  Amilton,Meta   Ct604380  Recarregando globais                 #
#---------------------------------------------------------------------------#
# 17/11/2008  Nilo           PSI230650 Decreto - 6523                       #
#---------------------------------------------------------------------------#
# 24/11/2008 Priscila Staingel 230650  Nao utilizar a 1 posicao do assunto  #
#                                      como sendo o agrupamento, buscar cod #
#                                      agrupamento.                         #
#---------------------------------------------------------------------------#
# 26/12/2008 Priscila Staingel 234915  Solicitar periodo de busca quando for#
#                                      informado SUSEP sem docto            #
#---------------------------------------------------------------------------#
# 10/03/2009 Carla Rampazzo PSI 235580 Auto Jovem-Curso Direcao Defensiva   #
#                                      Mostrar Nro.do Agendamento           #
#---------------------------------------------------------------------------#
# 29/12/2009 Patricia W.               Projeto SUCCOD - Smallint            #
#---------------------------------------------------------------------------#
# 10/03/2010 Carla Rampazzo PSI 219444 Filtrar ligacoes para exibir somente #
#                                      as ligacoes do Local Risco / Bloco   #
#---------------------------------------------------------------------------#
# 22/04/2010 Roberto Melo   PSI 242853 Implementacao do PSS                 #
#---------------------------------------------------------------------------#
# 11/10/2010 Carla Rampazzo PSI 260606 Tratar Fluxo de Reclamacao p/PSS(107)#
#---------------------------------------------------------------------------#
# 03/11/2010 Carla Rampazzo PSI 000762 Inclusao da tecla (F5)Prest - HDK    #
#---------------------------------------------------------------------------#
# 10/02/2011 Carla Rampazzo PSI        Fluxo de Reclamacao p/ PortoSeg(518) #
#---------------------------------------------------------------------------#
# 16/11/2015 Alberto                   Projeto HP                           #
#---------------------------------------------------------------------------#
#############################################################################


globals "/homedsa/projetos/geral/globals/glct.4gl"

 define m_prep       smallint,
        m_c24usrtip  like datmligacao.c24usrtip,
        m_c24empcod  like datmligacao.c24empcod,
        m_acessa     smallint

 define am_cta02m02 array[500] of record
    linha        char(01) 			---> Decreto - 6523
   ,atdnum       like datmatd6523.atdnum	---> Decreto - 6523
   ,ligdat       like datmligacao.ligdat
   ,lighorinc    like datmligacao.lighorinc
   ,funnom       like isskfunc.funnom
   ,c24solnom    like datmligacao.c24solnom
   ,c24soltipdes like datksoltip.c24soltipdes
   ,srvtxt       char (14)
   ,prpmrc       char (1)
   ,c24astcod    char (04)
   ,c24astdes    char (72)
   ,c24paxnum    like datmligacao.c24paxnum
   ,msgenv       char (01)
   ,atdetpdes    like datketapa.atdetpdes
   ,atdsrvnum    like datrligsrv.atdsrvnum
   ,atdsrvano    like datrligsrv.atdsrvano
   ,sinvstnum    like datrligsinvst.sinvstnum
   ,sinvstano    like datrligsinvst.sinvstano
   ,ramcod       like datrligsinvst.ramcod
   ,sinavsnum    like datrligsinavs.sinavsnum
   ,sinavsano    like datrligsinavs.sinavsano
   ,sinnum       like datrligsin.sinnum
   ,sinano       like datrligsin.sinano
   ,vstagnnum    like datrligagn.vstagnnum
   ,prporg       like datrligprp.prporg
   ,prpnumdig    like datrligprp.prpnumdig
 end record

 ---> Decreto - 6523
 define am2_cta02m02 array[500] of record
        lignum       like datmligacao.lignum,
        msg_sms      char(20)
 end record

 define mr_ws record
    atdsrvnum_rcl like datmservico.atdsrvnum
   ,atdsrvano_rcl like datmservico.atdsrvano
   ,atdsrvorg_rcl like datmservico.atdsrvorg
   ,funmat        like datmligacao.c24funmat
   ,atdetpcod     like datketapa.atdetpcod
   ,atdsrvorg     like datmservico.atdsrvorg
   ,atdprscod     like datmservico.atdprscod
   ,c24rclsitcod  like datmsitrecl.c24rclsitcod
   ,data          char (10)
   ,hora          char (05)
   ,c24astexbflg  like datkassunto.c24astexbflg
   ,ligsinpndflg  like datrligsin.ligsinpndflg
   ,pnd           char(01)
   ,vstagnnum     like datrligagn.vstagnnum
   ,vstagnstt     like datrligagn.vstagnstt
   ,lignum        like datmligacao.lignum
   ,msgtxt        char(40)
   ,ret           char(01)
   ,etp           char(05)
   ,trpavbnum     like datrligtrpavb.trpavbnum
   ,refatdsrvnum  like datmsrvjit.refatdsrvnum
   ,refatdsrvano  like datmsrvjit.refatdsrvano
   ,lignumjre     like datmligacao.lignum
   ,c24astcodjre  like datmligacao.c24astcod
   ,crtsaunum     like datksegsau.crtsaunum
   ,drscrsagdcod  like datrdrscrsagdlig.drscrsagdcod
   ,lclnumseq     like datmrsclcllig.lclnumseq
   ,rmerscseq     like datmrsclcllig.rmerscseq
 end record

 define am_aux array[500] of record
    cnslignum like datrligcnslig.cnslignum
 end record

 define m_arr_aux      smallint

#-----------------------#
function cta02m02_prep()
#-----------------------#
 define l_sql char(300)

 let l_sql = ' select a.cornom '
              ,' from gcakcorr a, gcaksusep b '
             ,' where b.corsus = ? '
               ,' and a.corsuspcp = b.corsuspcp '
 prepare p_cta02m02_001 from l_sql
 declare c_cta02m02_001 cursor for p_cta02m02_001

 let l_sql = " select funnom "
              ," from isskfunc "
             ," where funmat = ? "
               ," and empcod = ? "
               ," and usrtip = 'F' "
 prepare p_cta02m02_002 from l_sql
 declare c_cta02m02_002 cursor for p_cta02m02_002

 let l_sql = " select c24usrtip, ",
                    " c24empcod ",
               " from datmligacao ",
              " where lignum = ? "
 prepare p_cta02m02_003 from l_sql
 declare c_cta02m02_003 cursor for p_cta02m02_003

 ---> Sequencia do Local de Risco e Bloco do Condominio - RE
 let l_sql = " select lclnumseq "
                  ," ,rmerscseq "
              ," from datmrsclcllig "
             ," where lignum = ? "
 prepare p_cta02m02_004 from l_sql
 declare c_cta02m02_004 cursor for p_cta02m02_004

 let l_sql = " select atdcstvlr from datmservico ",
             " where pgtdat is not null          ",
             " and atdsrvnum = ?                 ",
             " and atdsrvano = ?                 "
 prepare pcta02m0205 from l_sql
 declare ccta02m0205 cursor for pcta02m0205
 let m_prep = true

end function

#----------------------------------#
function cta02m02_prepare(lr_param, l_dtini, l_dtfim) #PSI234915
#----------------------------------#
 define lr_param record
    succod    like datrligapol.succod
   ,ramcod    like datrligapol.ramcod
   ,aplnumdig like datrligapol.aplnumdig
   ,itmnumdig like datrligapol.itmnumdig
   ,prporg    like datrligprp.prporg
   ,prpnumdig like datrligprp.prpnumdig
   ,fcapacorg like datrligpac.fcapacorg
   ,fcapacnum like datrligpac.fcapacnum
   ,apoio     char(01)
   ,corsus    like datrligcor.corsus
   ,cgccpfnum like gsakseg.cgccpfnum
   ,cgcord    like gsakseg.cgcord
   ,cgccpfdig like gsakseg.cgccpfdig
   ,funmat    like datmligacao.c24funmat
   ,ctttel    like datmreclam.ctttel
   ,cmnnumdig like pptmcmn.cmnnumdig
   ,funmatatd like datmligatd.apomat
   ,crtsaunum like datksegsau.crtsaunum
   ,bnfnum    like datksegsau.bnfnum
   ,ramgrpcod like gtakram.ramgrpcod
 end record

 define l_dtini  date,       #PSI234915
        l_dtfim  date        #PSI234915

 define l_sql_comando char(300)
       ,l_cornom      char(40)
       ,l_funnom      char(20)
       ,l_cabec       char(60)
       ,l_cartao      char(21)
       ,l_empcod      like isskfunc.empcod

 define lr_cty22g00 record
 	     cont integer        ,
 	     sucursais char(100)
 end record
 if m_prep is null or m_prep <> true then
    call cta02m02_prep()
 end if

 let l_sql_comando = null
 let l_cornom = null
 let l_funnom = null
 let l_cabec  = null
 initialize lr_cty22g00.* to null
 let lr_cty22g00.cont   = false

 while true

          # Bloco 1
          if lr_param.apoio = "S" and
             lr_param.aplnumdig is null  and
             lr_param.prpnumdig is null  and
             lr_param.fcapacnum is null  then
             let l_sql_comando = ' select lignum '
                                  ,' from datmligatd '
                                 ,' where apoemp = ? '
                                   ,' and apomat = ? '
                                 ,' order by lignum '
             let l_empcod = 1
             open c_cta02m02_002 using lr_param.funmatatd, l_empcod
             whenever error continue
             fetch c_cta02m02_002 into l_funnom
             whenever error stop
             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode = 100 then
                   let l_funnom = "Funcionario nao cadastrado "
                else
                   error "ERRO SELECT DATRLIGCGCCPF. ", sqlca.sqlcode, ' - ',sqlca.sqlerrd[2] sleep 2
                   error "cta02m02_prepare() / ", lr_param.funmat sleep 2
                   return false
                end if
             end if
             let l_cabec = "ATENDENTE.: ",lr_param.funmatatd," ",l_funnom
             exit while
          end if


          # Bloco 2
          if lr_param.succod    is not null  and
             lr_param.ramcod    is not null  and
             lr_param.aplnumdig is not null  then

             # Bloco 2.1
             if lr_param.ramgrpcod =  5  then
                call cts20g16_formata_cartao(lr_param.crtsaunum)
                      returning l_cartao
                let l_cabec = "Cartao Saude: ", l_cartao
                let l_sql_comando = " select lignum ",
                                    " from datrligsau ",
                                    " where bnfnum = ? ",
                                    " order by lignum "
                                    
               display "l_sql_comando: ", l_sql_comando
                                    
               exit while
             end if

             # Bloco 2.2
             if g_documento.ciaempcod = 35  then
                let l_cabec = "Suc: ", lr_param.succod    using "&&&&&",
                            "  Ramo: ",lr_param.ramcod    using "&&&&",
                            "  Apl.: ",lr_param.aplnumdig using "<<<<<<<<#"
                if lr_param.itmnumdig is not null  and
                   lr_param.itmnumdig <>  0        then
                   let l_cabec = l_cabec clipped,
                                 "  Item: ", lr_param.itmnumdig using "<<<<<<#"
                end if
             else
                if g_documento.ciaempcod = 84 then # Itau
                    let l_cabec = "Cia: " , g_documento.itaciacod using "&&",
                                 " Suc: ", lr_param.succod    using "&&&&&",
                                 " Ramo: ",lr_param.ramcod    using "&&&&",
                                 " Apl.: ",lr_param.aplnumdig using "<<<<<<<<#"
                    if lr_param.itmnumdig is not null  and
                       lr_param.itmnumdig <>  0        then
                       let l_cabec = l_cabec clipped,
                                     "  Item: ", lr_param.itmnumdig using "<<<<<<#"
                    end if
                else
                    let l_cabec = "Suc: ", lr_param.succod    using "&&&&&",#using "&&", #projeto succcod
                                "  Ramo: ",lr_param.ramcod    using "&&&&",
                                "  Apl.: ",lr_param.aplnumdig using "<<<<<<<# #"
                    if lr_param.itmnumdig is not null  and
                       lr_param.itmnumdig <>  0        then
                       let l_cabec = l_cabec clipped,
                                     "  Item: ", lr_param.itmnumdig using "<<<<<# #"
                    end if
                end if
             end if

             if g_documento.ciaempcod = 84 then # Itau

                call cty22g00_rec_sucursal_itau(g_documento.itaciacod,
                                                lr_param.succod      ,
                                                lr_param.ramcod      ,
                                                lr_param.aplnumdig   ,
                                                lr_param.itmnumdig   )
                returning lr_cty22g00.cont ,
                          lr_cty22g00.sucursais
                if lr_cty22g00.cont then
                    let l_sql_comando = " select a.lignum             ",
                                          " from datrligapol a,       ",
                                          "      datrligitaaplitm b   ",
                                          " where a.lignum = b.lignum ",
                                          " and a.succod    in ", lr_cty22g00.sucursais clipped ,
                                          " and a.ramcod    = ? ",
                                          " and a.aplnumdig = ? ",
                                          " and a.itmnumdig = ? ",
                                          " and b.itaciacod = ? ",
                                          " order by a.lignum   "
                else
                	   let l_sql_comando = " select a.lignum      ",
                                          " from datrligapol a,       ",
                                          "      datrligitaaplitm b   ",
                                          " where a.lignum = b.lignum ",
                                          " and a.succod    = ? ",
                                          " and a.ramcod    = ? ",
                                          " and a.aplnumdig = ? ",
                                          " and a.itmnumdig = ? ",
                                          " and b.itaciacod = ? ",
                                          " order by a.lignum   "
                end if
                exit while

                else
                  let l_sql_comando = " select lignum ",
                                        " from datrligapol ",
                                       " where succod    = ? ",
                                         " and ramcod    = ? ",
                                         " and aplnumdig = ? ",
                                         " and itmnumdig = ? ",
                                       " order by lignum "
                  exit while
                end if
           end if


          # Bloco 3
          if g_pss.psscntcod is not null then # PSS
             let l_cabec = "Contrato: ", g_pss.psscntcod using "&&&&&&&&&&"
             let l_sql_comando = "select lignum              ",
                                 "  from datrcntlig       ",
                                 " where psscntcod = ?       ",
                                 " order by lignum desc      "
             exit while
          end if


          # Bloco 4
          if lr_param.prporg is not null and
             lr_param.prpnumdig is not null then
             let l_cabec = "Proposta: ", lr_param.prporg    using "&&", " ",
                                         lr_param.prpnumdig using "<<<<<<<<&"
             let l_sql_comando = " select lignum "
                                  ," from datrligprp "
                                 ," where prporg    = ? "
                                   ," and prpnumdig = ? "
                                 ," order by lignum "
             exit while
          end if


          # Bloco 5
          if lr_param.fcapacorg is not null and
             lr_param.fcapacnum is not null then
             let l_cabec = "No.PAC: ", lr_param.fcapacorg using "&&",
                                  " ", lr_param.fcapacnum using "<<<<<<<<&"
             let l_sql_comando = " select lignum "
                                  ," from datrligpac "
                                 ," where fcapacorg = ? "
                                   ," and fcapacnum = ? "
                                 ," order by lignum "
             exit while
          end if


          # Bloco 6
          if lr_param.cmnnumdig is not null then
             let l_cabec = "Contrato: ", lr_param.cmnnumdig
             let l_sql_comando = " select lignum "
                                  ," from datrligppt "
                                 ," where cmnnumdig = ? "
                                 ," order by lignum "
             exit while
          end if


          # Bloco 7
          if lr_param.corsus is not null then
             open c_cta02m02_001 using lr_param.corsus
             whenever error continue
                fetch c_cta02m02_001 into l_cornom
             whenever error stop
             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode = 100 then
                   let l_cornom = "Corretor nao cadastrado na Porto "
                else
                   error "ERRO SELECT GCAKCORR. ", sqlca.sqlcode, ' - ',sqlca.sqlerrd[2] sleep 2
                   error "cta02m02_prepare() / ", lr_param.corsus sleep 2
                   return false
                end if
             end if
             let l_cabec = "SUSEP.: ",lr_param.corsus," ",l_cornom
             #PSI 234915 - se periodo foi informado busca ligacoes dentro do periodo
             # senão busca todas as ligacoes, mantendo a regra que existe hoje
             if l_dtini is not null and
                l_dtfim is not null then
                let l_sql_comando = " select a.lignum "
                                   ," from datrligcor a, datmligacao b "
                                   ," where a.lignum = b.lignum "
                                   ,"   and a.corsus = ? "
                                   ,"   and b.ligdat >= ? "
                                   ,"   and b.ligdat <= ? "
             else
             	let l_sql_comando = " select lignum "
                	           ," from datrligcor "
                        	   ," where corsus = ? "
             end if
             exit while
          end if


          # Bloco 8
          if lr_param.cgccpfnum is not null then
             let l_cabec = 'CGC/CPF.: ',lr_param.cgccpfnum,
                                    ' ',lr_param.cgcord,
                                    ' ',lr_param.cgccpfdig
             let l_sql_comando = 'select a.lignum        ',
                                 '  from datrligcgccpf a,',
                                 '       datmligacao b   ',
                                 ' where a.lignum = b.lignum ',
                                 '   and a.cgccpfnum = ? ',
                                 '   and a.cgcord    = ? ',
                                 '   and a.cgccpfdig = ? '
             # Quando empresa 40 e 43 cartao exibe servico da empresa 43 pss
             if g_documento.ciaempcod = 40 or g_documento.ciaempcod = 43 then
                let l_sql_comando = l_sql_comando clipped,
                                   ' and b.ciaempcod in (40,43) '
             else
                let l_sql_comando = l_sql_comando clipped,
                                   ' and b.ciaempcod = ', g_documento.ciaempcod
             end if

             let l_sql_comando = l_sql_comando clipped,
                                 ' order by a.lignum desc '

             exit while
          end if


          # Bloco 9
          if lr_param.funmat is not null then
             open c_cta02m02_002 using lr_param.funmat, g_documento.empcodmat
             whenever error continue
             fetch c_cta02m02_002 into l_funnom
             whenever error stop
             if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode = 100 then
                   let l_funnom = "Funcionario nao cadastrado "
                else
                   error "ERRO SELECT DATRLIGCGCCPF. ", sqlca.sqlcode, ' - ',sqlca.sqlerrd[2] sleep 2
                   error "cta02m02_prepare() / ", lr_param.funmat sleep 2
                   return false
                end if
             end if
             let l_cabec = "FUNCION.: ",lr_param.funmat," ",l_funnom
             if l_dtini is not null and
                l_dtfim is not null then
                let l_sql_comando =  " select a.lignum "
                                   ," from datrligmat a, datmligacao b "
                                   ," where a.lignum = b.lignum "
                                   ,"   and a.funmat = ? "
                                   ,"   and b.ligdat >= ? "
                                   ,"   and b.ligdat <= ? "
             else
                let l_sql_comando = " select lignum ",
                                    " from datrligmat",
                                    " where funmat = ? "
             end if


             exit while
          end if


          # Bloco 10
          if lr_param.ctttel is not null then
             let l_cabec = 'TELEFONE.: ',lr_param.ctttel
             let l_sql_comando = " select lignum "
                                  ," from datrligtel "
                                 ," where teltxt = ? "
             exit while
          end if


           # Bloco 11
           if g_cgccpf.ligdctnum is not null and  #Verifica se o Atendimento via VP ou CP
              g_cgccpf.ligdcttip is not null then
              let l_sql_comando = "select lignum              ",
                                  "  from datrligsemapl       ",
                                  " where ligdctnum = ?       ",
                                  " and ligdcttip = ?         "
                ----              " order by lignum desc      "
                --> Order by inibido pois estava muito demorado
              case g_cgccpf.ligdcttip
                 when 1
                      let l_cabec = 'Vistoria.: ',g_cgccpf.ligdctnum
                 when 2
                      let l_cabec = 'Cobertura.: ',g_cgccpf.ligdctnum
              end case
              exit while
           end if

          exit while

  end while

 prepare sel_cta02m02 from l_sql_comando
 declare c_cta02m02 cursor for sel_cta02m02

 return true, l_cabec

end function

#---------------------------------------------#
function cta02m02_consultar_ligacoes(lr_param)
#---------------------------------------------#
 define lr_param record
    succod       like datrligapol.succod
   ,ramcod       like datrligapol.ramcod
   ,aplnumdig    like datrligapol.aplnumdig
   ,itmnumdig    like datrligapol.itmnumdig
   ,prporg       like datrligprp.prporg
   ,prpnumdig    like datrligprp.prpnumdig
   ,fcapacorg    like datrligpac.fcapacorg
   ,fcapacnum    like datrligpac.fcapacnum
   ,apoio        char(01)
   ,corsus       like datrligcor.corsus
   ,cgccpfnum    like gsakseg.cgccpfnum
   ,cgcord       like gsakseg.cgcord
   ,cgccpfdig    like gsakseg.cgccpfdig
   ,funmat       like datmligacao.c24funmat
   ,ctttel       like datmreclam.ctttel
   ,cmnnumdig    like pptmcmn.cmnnumdig
   ,solnom       char(15)
   ,c24soltipcod like datmligacao.c24soltipcod
   ,empcodatd    like datmligatd.apoemp
   ,funmatatd    like datmligatd.apomat
   ,crtsaunum    like datksegsau.crtsaunum
   ,bnfnum       like datksegsau.bnfnum
   ,ramgrpcod    like gtakram.ramgrpcod
 end record

 define lr_resultado record
        resultado    smallint,
        mensagem     char(80),
        cabec        char(60)
 end record

 define lr_cts20g14_motivo_con record
    resultado smallint
   ,mensagem  char(100)
 end record

 ---> Decreto - 6523
 define lr_atend        record
        atdnum_new      like datmatd6523.atdnum
 end record

 define l_rcuccsmtvdes like datkrcuccsmtv.rcuccsmtvdes
       ,l_cabtip       char(01)
       ,l_conflg       char(01)
       ,l_linha1       char(40)
       ,l_linha2       char(40)
       ,l_resp         char(01)
       ,aux_lixo       char(01)
       ,l_corsussol    char(06)
       ,l_assunto      like datkrcuccsmtv.c24astcod
       ,l_rcuccsmtvcod like datrligrcuccsmtv.rcuccsmtvcod
       ,l_flag_acesso  smallint

  define l_data     date,
         l_hora2    datetime hour to minute

 define l_erro     integer
       ,l_mens     char(40)
       ,l_msg_erro char(300)
       ,l_i        integer
       ,l_confirma char(1)
       ,l_numero_aviso_sinistro like sanmsin.sinnum
       ,l_ano_aviso_sinistro like sanmsin.sinano
       ,l_anoaux     char(04)
       ,l_c24astcod like datkrcuccsmtv.c24astcod

 define sin array[10] of record
        numero_aviso like sanmavs.sinavsnum
 end record

 define l_consulta smallint

 define lr_sinistro record
       sinramcod  like ssamsin.ramcod       ,
       sinano     like ssamsin.sinano       ,
       sinnum     like ssamsin.sinnum       ,
       sinitmseq  like ssamitem.sinitmseq   ,
       tipo       char(01)                  ,
       erro       smallint
 end record

 define cty27g00_ret integer # psi-2012-22101

 define lr_assunto record
        resultado smallint
       ,mensagem  char(100)
       ,c24astcod like datmligacao.c24astcod
       ,lignum    like datmligacao.lignum
 end record


#------------------------------
# Inicializa variaveis
#------------------------------

 initialize mr_ws, cty27g00_ret to null
 ---> Decreto - 6523
 initialize lr_atend.* to null

 let l_consulta = false

 let l_i = 1
 for l_i = 1 to 10
     initialize sin[l_i].* to null
 end for

 call cts40g03_data_hora_banco(2)
      returning l_data, l_hora2

 let l_rcuccsmtvdes = null
 let l_cabtip       = null
 let l_conflg       = null
 let l_linha1       = null
 let l_linha2       = null
 let l_resp         = null
 let m_arr_aux      = null
 let aux_lixo       = null
 let l_corsussol    = null
 let int_flag       = false
 let mr_ws.data     = l_data
 let mr_ws.hora     = l_hora2
 let l_rcuccsmtvcod = null
 let l_assunto      = null
 let l_anoaux       = null
 let l_c24astcod    = null

 initialize lr_cts20g14_motivo_con, am_cta02m02, am_aux, lr_resultado, lr_sinistro to null

 open window cta02m02 at 05,02 with form "cta02m02" attribute(form line 1,message line last - 1)

 let l_flag_acesso = cta00m06(g_issk.dptsgl)

 message " Aguarde, pesquisando..."  attribute(reverse)

 call cta02m02_pesquisar_ligacoes(1
                                 ,lr_param.succod
                                 ,lr_param.ramcod
                                 ,lr_param.aplnumdig
                                 ,lr_param.itmnumdig
                                 ,lr_param.prporg
                                 ,lr_param.prpnumdig
                                 ,lr_param.fcapacorg
                                 ,lr_param.fcapacnum
                                 ,lr_param.apoio
                                 ,lr_param.corsus
                                 ,lr_param.cgccpfnum
                                 ,lr_param.cgcord
                                 ,lr_param.cgccpfdig
                                 ,lr_param.funmat
                                 ,lr_param.ctttel
                                 ,lr_param.cmnnumdig
                                 ,lr_param.empcodatd
                                 ,lr_param.funmatatd
                                 ,lr_param.crtsaunum
                                 ,lr_param.bnfnum
                                 ,lr_param.ramgrpcod)
 returning lr_resultado.*
 if lr_resultado.resultado <> 1 then
    error lr_resultado.mensagem sleep 2
    close window cta02m02
    let int_flag = false
    return
 end if

 if g_issk.prgsgl = 'ctg2' or
    g_issk.prgsgl = "ctg2t" or
    g_issk.prgsgl = "ctg97" then
    message "(F17)Aband (F5)Prest (F6)Motivo (F7)Hist (F8)ALT,REC,CAN,RET,IND,CON (F9)Prop"
 else
    message " (F17)Abandona, (F6)Motivo, (F7)Historico, (F9)Prop"
 end if

 if l_flag_acesso = 0 then
    message " (F17)Abandona (F7)Historico (F8)ALT,CAN,RET,CON "
 end if

 ---> Decreto - 6523
 let lr_atend.atdnum_new = null
 let lr_atend.atdnum_new = g_documento.atdnum
 display by name lr_atend.atdnum_new attribute(reverse)

 if m_arr_aux = 1 then
    error  " Nao existem ligacoes para esta consulta!" sleep 2
 end if

 call cty40g00_carrega_assunto()
    let int_flag = false

    call set_count(m_arr_aux -1)

    options insert   key F35,
            delete   key F36,
            next     key F37,
            previous key F38

    input array am_cta02m02 without defaults from s_cta02m02.*

       before field linha
          let m_arr_aux = arr_curr()

          display by name am2_cta02m02[m_arr_aux].lignum attribute (reverse)
          if length(am_cta02m02[m_arr_aux].c24astcod) > 3  then
             let l_c24astcod = am_cta02m02[m_arr_aux].c24astcod[2,4]
          else
          	 let l_c24astcod = am_cta02m02[m_arr_aux].c24astcod
          end if
          if cty40g00_valida_assunto(l_c24astcod) then
          		let am2_cta02m02[m_arr_aux].msg_sms = "(F10) Reenviar SMS"
          		display by name am2_cta02m02[m_arr_aux].msg_sms
          		let m_acessa = true
          else
          	  let am2_cta02m02[m_arr_aux].msg_sms = null
          		display by name am2_cta02m02[m_arr_aux].msg_sms
          		let m_acessa = false
          end if

       after  field linha

          if fgl_lastkey() = fgl_keyval("left")  or
             fgl_lastkey() = fgl_keyval("up")    then
          else
             if am2_cta02m02[m_arr_aux+1].lignum is null or
                am2_cta02m02[m_arr_aux+1].lignum < 0     then
                error " There are no more rows in the direction ",
                      "you are going "
                next field linha
             end if
          end if

       on key (interrupt,control-c)
           exit input


       on key (F5)

          error ""
          let m_arr_aux = arr_curr()

          #--------------------------------------------
          --> Edita Mensagem para Prestador - Help Desk
          #--------------------------------------------
          call cty20g00_hst_prt(am_cta02m02[m_arr_aux].atdsrvnum
                               ,am_cta02m02[m_arr_aux].atdsrvano)
                      returning lr_resultado.resultado
                               ,lr_resultado.mensagem

          if lr_resultado.resultado = 1 then
             error lr_resultado.mensagem
          end if


       on key (F6)
          if l_flag_acesso = 1 then
             error ""
             let m_arr_aux = arr_curr()

             call cts46g00_consulta(am2_cta02m02[m_arr_aux].lignum) ---> Decreto - 6523
          end if

       #---------------------------------------------------------------------
       # Chama historico da ligacao
       #---------------------------------------------------------------------
       on key (F7)
          error ""
          let m_arr_aux = arr_curr()

          let g_lignum_dcr = null


          call cta02m19_historico(am_cta02m02[m_arr_aux].atdsrvnum
                                 ,am_cta02m02[m_arr_aux].atdsrvano
                                 ,am_cta02m02[m_arr_aux].sinvstnum
                                 ,am_cta02m02[m_arr_aux].sinvstano
                                 ,am_cta02m02[m_arr_aux].sinavsnum
                                 ,am_cta02m02[m_arr_aux].sinavsano
                                 ,am_aux[m_arr_aux].cnslignum
                                 ,am2_cta02m02[m_arr_aux].lignum) ---> Decreto - 6523
          # Replica Historico da Ligação para A Tela de Notas


          if length(am_cta02m02[m_arr_aux].c24astcod) > 3  then
             let am_cta02m02[m_arr_aux].c24astcod =
                 am_cta02m02[m_arr_aux].c24astcod[2,4]
          end if

          if am_cta02m02[m_arr_aux].c24astcod = "U10" or
             am_cta02m02[m_arr_aux].c24astcod = "U00" then

             call cts08g01('A','S',"DESEJA REPLICAR", " HISTORICO DA LIGACAO", " PARA TELA DE NOTAS ?", '')
             returning l_confirma

             if l_confirma = "S" then
                   call cta06m00_recupera_sinistro(am2_cta02m02[m_arr_aux].lignum)
                   returning lr_sinistro.sinramcod ,
                             lr_sinistro.sinano    ,
                             lr_sinistro.sinnum    ,
                             lr_sinistro.sinitmseq ,
                             lr_sinistro.erro
                   case lr_sinistro.sinramcod
                      when 531
                            let lr_sinistro.tipo = "S"
                      when 553
                            let lr_sinistro.tipo = "T"
                   end case
                   let lr_resultado.mensagem = "O PROCESSO ", lr_sinistro.sinnum    using '<<<<<&' , "/",
                                                              lr_sinistro.sinano                   , "/",
                                                              lr_sinistro.tipo                     ,
                                                              lr_sinistro.sinitmseq using '<&'     , "."
                   call cts08g01('A','S',"A INFORMAÇÃO SERÁ REPLICADA PARA ", lr_resultado.mensagem, " ESTA CERTO ?", '')
                   returning l_confirma
                   if l_confirma = "S" then
                        call cta06m00_replica_nota(am2_cta02m02[m_arr_aux].lignum)
                   end if
             end if
          end if
       #---------------------------------------------------------------------
       # Chamada para alteracao, reclamacao, cancelamento, consulta ou indicacao
       #---------------------------------------------------------------------
       on key (F8)
          if g_issk.prgsgl = "ctg2"  or
             g_issk.prgsgl = "ctg2t" or
             g_issk.prgsgl = "ctg97" then
             if g_issk.acsnivcod = 2 then
                error " Nivel de acesso somente para consulta!" sleep 2
             else
                let m_arr_aux = arr_curr()
                if length(am_cta02m02[m_arr_aux].c24astcod) > 3  then
                   let am_cta02m02[m_arr_aux].c24astcod =
                       am_cta02m02[m_arr_aux].c24astcod[2,4]
                end if

                call cta00m06_assunto_sinistro(am_cta02m02[m_arr_aux].c24astcod)
                     returning l_consulta


                if l_consulta = true then
                   call cts08g01("A", "","PARA REALIZACAO DE CONSULTA E/OU",
                                         "ALTERACAO ENTRAR COM O ASSUNTO ",
                                         "SIN",
                                         "")
                            returning l_confirma
                else
                    initialize lr_assunto.* to null
                    # Obter o Ligacao Original do Assunto pelo Servico
                    select min(lignum) into lr_assunto.lignum
                    from   datmligacao
                    where  atdsrvnum = am_cta02m02[m_arr_aux].atdsrvnum
                    and    atdsrvano = am_cta02m02[m_arr_aux].atdsrvano
                    ##-- Obter o assunto da ligacao consultada --##

                    call cts20g03_dados_ligacao( 2, lr_assunto.lignum  )
                    returning lr_assunto.resultado
                             ,lr_assunto.mensagem
                             ,lr_assunto.c24astcod
                    # consistir se faz parte do agrupamento.
                    # Se sim, buscar numero de proposta e armazenar na global.
                    call cty27g00_consiste_ast(lr_assunto.c24astcod)
                         returning cty27g00_ret
                    if cty27g00_ret = 1 then
                       let g_documento.prpnum = cty27g00_proposta(am_cta02m02[m_arr_aux].atdsrvnum,
                                                                  am_cta02m02[m_arr_aux].atdsrvano)
                       let g_documento.c24astcod = am_cta02m02[m_arr_aux].c24astcod # nao estava atualizando global(g_documento.c24astcod)
                       let g_documento.lignum    = am2_cta02m02[m_arr_aux].lignum   # nao estava atualizando global(g_documento.lignum)
                    end if

                    call cta02m21_chamada(am_cta02m02[m_arr_aux].atdetpdes
                                         ,am2_cta02m02[m_arr_aux].lignum	---> Decreto - 6523
                                         ,am_cta02m02[m_arr_aux].atdsrvnum
                                         ,am_cta02m02[m_arr_aux].atdsrvano
                                         ,am_cta02m02[m_arr_aux].sinvstnum
                                         ,am_cta02m02[m_arr_aux].sinvstano
                                         ,am_cta02m02[m_arr_aux].sinavsnum
                                         ,am_cta02m02[m_arr_aux].sinavsano
                                         ,am_cta02m02[m_arr_aux].c24astcod
                                         ,am_aux[m_arr_aux].cnslignum
                                         ,lr_param.solnom
                                         ,lr_param.c24soltipcod
                                         ,am_cta02m02[m_arr_aux].ramcod)
                end if


                # Função desativada devido ao projeto de unificacao dos assuntos
                # de sinistro.
                {
                if am_cta02m02[m_arr_aux].c24astcod = "N10" or
                   am_cta02m02[m_arr_aux].c24astcod = "N11" or
                   am_cta02m02[m_arr_aux].c24astcod = "F10" then

                     if am_cta02m02[m_arr_aux].atdsrvnum is not null  and
                        am_cta02m02[m_arr_aux].atdsrvano is not null  then
                        let l_anoaux = "20",am_cta02m02[m_arr_aux].atdsrvano
                        let l_numero_aviso_sinistro = am_cta02m02[m_arr_aux].atdsrvnum
                        let l_ano_aviso_sinistro    = l_anoaux
                     end if

                     if am_cta02m02[m_arr_aux].sinvstnum is not null  and
                        am_cta02m02[m_arr_aux].sinvstano is not null  then
                        let l_numero_aviso_sinistro = am_cta02m02[m_arr_aux].sinvstnum
                        let l_ano_aviso_sinistro    = am_cta02m02[m_arr_aux].sinvstano
                     end if

                     if am_cta02m02[m_arr_aux].sinavsnum is not null  and
                        am_cta02m02[m_arr_aux].sinavsano is not null  then
                        let l_numero_aviso_sinistro = am_cta02m02[m_arr_aux].sinavsnum
                        let l_ano_aviso_sinistro    = am_cta02m02[m_arr_aux].sinavsano
                     end if

                     if am_cta02m02[m_arr_aux].sinnum is not null  and
                        am_cta02m02[m_arr_aux].sinano is not null  then
                        let l_numero_aviso_sinistro = am_cta02m02[m_arr_aux].sinnum
                        let l_ano_aviso_sinistro    = am_cta02m02[m_arr_aux].sinano
                     end if


                   call ssata100_consulta_avisoweb_central24h_f8(
                                                l_numero_aviso_sinistro,
                                                l_ano_aviso_sinistro,
                                                lr_param.succod,
                                                lr_param.aplnumdig,
                                                lr_param.itmnumdig,
                                                lr_param.prporg,
                                                lr_param.prpnumdig,
                                                am_cta02m02[m_arr_aux].c24astcod)
                        returning l_erro, l_msg_erro,
                               sin[1].numero_aviso, sin[2].numero_aviso,
                               sin[3].numero_aviso, sin[4].numero_aviso,
                               sin[5].numero_aviso, sin[6].numero_aviso,
                               sin[7].numero_aviso, sin[8].numero_aviso,
                               sin[9].numero_aviso, sin[10].numero_aviso



                    let l_mens = sin[1].numero_aviso

                    let l_i = 2
                    for l_i = 2 to 10
                        if sin[l_i].numero_aviso is null or
                           sin[l_i].numero_aviso = 0 then
                          exit for
                        else
                          let l_mens = l_mens clipped,", ",sin[l_i].numero_aviso
                        end if
                    end for
                    if l_erro = 0 then
                         call cts08g01("A", "","Este aviso foi preenchido na WEB",
                                            "Consultar na WEB pela opção ",
                                            "Nr.de Aviso o(s) seguinte(s) número(s):",
                                            l_mens)
                         returning l_confirma
                    else
                        if l_erro = 100 then
                           call cta02m21_chamada(am_cta02m02[m_arr_aux].atdetpdes
                                                ,am2_cta02m02[m_arr_aux].lignum	---> Decreto - 6523
                                                ,am_cta02m02[m_arr_aux].atdsrvnum
                                                ,am_cta02m02[m_arr_aux].atdsrvano
                                                ,am_cta02m02[m_arr_aux].sinvstnum
                                                ,am_cta02m02[m_arr_aux].sinvstano
                                                ,am_cta02m02[m_arr_aux].sinavsnum
                                                ,am_cta02m02[m_arr_aux].sinavsano
                                                ,am_cta02m02[m_arr_aux].c24astcod
                                                ,am_aux[m_arr_aux].cnslignum
                                                ,lr_param.solnom
                                                ,lr_param.c24soltipcod
                                                ,am_cta02m02[m_arr_aux].ramcod)
                        else
                           error "ERRO NA FUNCAO SSATA100 ! <",l_msg_erro ,">"
                        end if
                    end if
                else
                call cta02m21_chamada(am_cta02m02[m_arr_aux].atdetpdes
                                     ,am2_cta02m02[m_arr_aux].lignum	---> Decreto - 6523
                                     ,am_cta02m02[m_arr_aux].atdsrvnum
                                     ,am_cta02m02[m_arr_aux].atdsrvano
                                     ,am_cta02m02[m_arr_aux].sinvstnum
                                     ,am_cta02m02[m_arr_aux].sinvstano
                                     ,am_cta02m02[m_arr_aux].sinavsnum
                                     ,am_cta02m02[m_arr_aux].sinavsano
                                     ,am_cta02m02[m_arr_aux].c24astcod
                                     ,am_aux[m_arr_aux].cnslignum
                                     ,lr_param.solnom
                                     ,lr_param.c24soltipcod
                                     ,am_cta02m02[m_arr_aux].ramcod)
                end if}
             end if
              # CT - 604380 INICIO #
              # Regarregando as globais que estão sendo zeradas pela função cts20g01_docto #
              call cta02m02_recarrega_globais(lr_param.succod
                                              ,lr_param.ramcod
                                              ,lr_param.aplnumdig
                                              ,lr_param.itmnumdig
                                              ,lr_param.prporg
                                              ,lr_param.prpnumdig )
              # Replica Historico da Ligação para A Tela de Notas

              if am_cta02m02[m_arr_aux].c24astcod = "U10" or
                 am_cta02m02[m_arr_aux].c24astcod = "U00" then

                 call cts08g01('A','S',"DESEJA REPLICAR", " HISTORICO DA LIGACAO", " PARA TELA DE NOTAS ?", '')
                 returning l_confirma

                 if l_confirma = "S" then
                      call cta06m00_recupera_sinistro(am2_cta02m02[m_arr_aux].lignum)
                      returning lr_sinistro.sinramcod ,
                                lr_sinistro.sinano    ,
                                lr_sinistro.sinnum    ,
                                lr_sinistro.sinitmseq ,
                                lr_sinistro.erro
                      case lr_sinistro.sinramcod
                         when 531
                               let lr_sinistro.tipo = "S"
                         when 553
                               let lr_sinistro.tipo = "T"
                      end case

                      let lr_resultado.mensagem = "O PROCESSO ", lr_sinistro.sinnum using '<<<<<&'   , "/",
                                                                 lr_sinistro.sinano                  , "/",
                                                                 lr_sinistro.tipo                    ,
                                                                 lr_sinistro.sinitmseq using '<&'    , "."

                      call cts08g01('A','S',"A INFORMAÇÃO SERÁ REPLICADA PARA ", lr_resultado.mensagem, " ESTA CERTO ?", '')
                      returning l_confirma
                      if l_confirma = "S" then
                           call cta06m00_replica_nota(am2_cta02m02[m_arr_aux].lignum)
                      end if
                 end if
              end if



              # CT - 604380 FIM #

          end if

       on key (F9)
          if l_flag_acesso = 1 then
             let m_arr_aux = arr_curr()
             if am_cta02m02[m_arr_aux].prpmrc = "*" then
                let mr_ws.msgtxt = "Proposta: ",
                                am_cta02m02[m_arr_aux].prporg    using "&&", "-",
                                am_cta02m02[m_arr_aux].prpnumdig using "&&&&&&&&"
                call cts08g01("A", "", "Atendimento efetuado pela ", mr_ws.msgtxt,
                              "", "")
                     returning mr_ws.ret
             end if
          end if
        on key (F10)
        	if m_acessa then
        		 call cty40g00(l_c24astcod)
        		 call cty40g00_grava_historico(am_cta02m02[m_arr_aux].atdsrvnum,
        		                               am_cta02m02[m_arr_aux].atdsrvano,
        		                               am2_cta02m02[m_arr_aux].lignum   )
        	end if

    end input

 let int_flag = false
 close window cta02m02

end function ##-- cta02m02_consultar_ligacoes()


#---------------------------------------------#
function cta02m02_pesquisar_ligacoes(lr_param)
#---------------------------------------------#
 define lr_param record
    nivel_retorno smallint
   ,succod    like datrligapol.succod
   ,ramcod    like datrligapol.ramcod
   ,aplnumdig like datrligapol.aplnumdig
   ,itmnumdig like datrligapol.itmnumdig
   ,prporg    like datrligprp.prporg
   ,prpnumdig like datrligprp.prpnumdig
   ,fcapacorg like datrligpac.fcapacorg
   ,fcapacnum like datrligpac.fcapacnum
   ,apoio     char(01)
   ,corsus    like datrligcor.corsus
   ,cgccpfnum like gsakseg.cgccpfnum
   ,cgcord    like gsakseg.cgcord
   ,cgccpfdig like gsakseg.cgccpfdig
   ,funmat    like datmligacao.c24funmat
   ,ctttel    like datmreclam.ctttel
   ,cmnnumdig like pptmcmn.cmnnumdig
   ,empcodatd like datmligatd.apoemp
   ,funmatatd like datmligatd.apomat
   ,crtsaunum like datksegsau.crtsaunum
   ,bnfnum    like datksegsau.bnfnum
   ,ramgrpcod like gtakram.ramgrpcod
 end record

 define lr_saida  record
        resultado smallint
       ,mensagem  char(100)
       ,cabec     char(60)
 end record

 define lr_cts20g14_motivo_con record
    resultado smallint
   ,mensagem  char(100)
 end record

 define l_c24soltipcod like datksoltip.c24soltipcod
       ,l_c24astcod    like datmligacao.c24astcod
       ,l_aux_ano2     decimal(2,0)
       ,l_aux          char(10)
       ,l_aux_ano4     char(04)
       ,l_aux_char     char(04)
       ,l_astcod       char(04)
       ,l_mstnum       like datrligmens.mstnum
       ,l_assunto      like datkrcuccsmtv.c24astcod
       ,l_rcuccsmtvcod like datrligrcuccsmtv.rcuccsmtvcod
       ,l_canmtvdes    like datmvstsincanc.canmtvdes
       ,l_ok           smallint
       ,l_flag_acesso  smallint
       ,l_acesso       smallint
       ,l_c24astagp    like datkassunto.c24astagp    ##psi230650

 define l_data_inicial  date,         #PSI234915
        l_data_final    date,         #PSI234915
        l_confirma      char(1),
        l_tot_serv      integer,
        l_qtd_serv      integer,
        l_vlr_serv      integer

 define l_mensa      record
        msg          char(200)
       ,de           char(50)
       ,subject      char(100)
       ,para         char(100)
       ,cc           char(100)
 end record

 define l_today date
 define l_hora  datetime hour to second
 define l_cmd   char(500)
 define l_valor decimal(8,2)
 define l_qtd   integer
 define l_envia integer

 define cty08g00_func record
        funnom       like isskfunc.funnom,
        mens         char(40),
        resultado    smallint
 end record

 initialize cty08g00_func.* to null
 initialize lr_cts20g14_motivo_con to null
 initialize lr_saida to null
 initialize am_cta02m02 to null
 initialize am2_cta02m02 to null

 initialize l_valor, l_qtd to null

 let l_c24soltipcod = null
 let l_c24astcod    = null
 let l_aux_ano2     = null
 let l_assunto      = null
 let l_astcod       = null
 let l_aux_char     = null
 let l_aux_ano4     = null
 let l_aux          = null
 let l_mstnum       = null
 let l_rcuccsmtvcod = null
 let l_c24astagp    = null        ##psi230650
 let l_confirma     = null
 let l_data_inicial = null        #PSI234915
 let l_data_final   = null        #PSI234915
 let l_acesso       = 0
 let l_qtd_serv     = 0
 let l_tot_serv     = 0
 let l_vlr_serv     = null
 let l_envia        = 0

 let l_flag_acesso = cta00m06(g_issk.dptsgl)

 #PSI 234915 - se foi informado SUSEP sem docto, solicita periodo de busca
 # apenas quando for buscar ligacoes para retornar para a tela de assunto

 if lr_param.nivel_retorno = 2 and
    g_documento.semdocto = 'S' and
    (lr_param.corsus is not null  or
     lr_param.funmat is not null) then
   	call cta02m02_informa_filtro_susep(lr_param.corsus,lr_param.funmat)
        returning l_data_inicial, l_data_final
        let g_filtro.inicial = l_data_inicial
        let g_filtro.final   = l_data_final
 end if

 if lr_param.nivel_retorno = 1    and
   (lr_param.corsus is not null   or
    lr_param.funmat is not null ) then
      if g_filtro.inicial is not null then
         call cts08g01("A","S",""
                       ,"DESEJA MANTER O FILTRO DO PERIODO ? ","","")
              returning l_confirma

          if l_confirma = "S" then
             let l_data_inicial = g_filtro.inicial
             let l_data_final   = g_filtro.final
          end if
      end if
 end if
 call cta02m02_prepare(lr_param.succod
                      ,lr_param.ramcod
                      ,lr_param.aplnumdig
                      ,lr_param.itmnumdig
                      ,lr_param.prporg
                      ,lr_param.prpnumdig
                      ,lr_param.fcapacorg
                      ,lr_param.fcapacnum
                      ,lr_param.apoio
                      ,lr_param.corsus
                      ,lr_param.cgccpfnum
                      ,lr_param.cgcord
                      ,lr_param.cgccpfdig
                      ,lr_param.funmat
                      ,lr_param.ctttel
                      ,lr_param.cmnnumdig
                      ,lr_param.funmatatd
                      ,lr_param.crtsaunum
                      ,lr_param.bnfnum
                      ,lr_param.ramgrpcod
                      ,l_data_inicial            #PSI234915
                      ,l_data_final)             #PSI234915
      returning l_ok, lr_saida.cabec

 if l_ok = false then
    let lr_saida.resultado = 3
    let lr_saida.mensagem = 'Erro na preparacao dos cursores '
    return lr_saida.*
 end if

#---------------------------------------------------------------------------
# Gera tabela temporaria para UNIR ligacoes da apolice com as da proposta
#---------------------------------------------------------------------------
 whenever error continue
 drop table cta02m02_tmp
 create temp table cta02m02_tmp( lignum    decimal(10,0),
                                 prpmrc    char(1),
                                 prporg    decimal(2,0),
                                 prpnumdig decimal(8,0) )
                                 with no log
 whenever error stop

 message "Aguarde, pesquisando ... "

 ##-- Obter as ligacoes de acordo com os parametros --##
 call cta02m02_obter_ligacoes(lr_param.apoio,
                              lr_param.empcodatd,
                              lr_param.funmatatd,
                              lr_param.succod,
                              lr_param.ramcod,
                              lr_param.aplnumdig,
                              lr_param.itmnumdig,
                              lr_param.prporg,
                              lr_param.prpnumdig,
                              lr_param.fcapacorg,
                              lr_param.fcapacnum,
                              lr_param.cmnnumdig,
                              lr_param.corsus,
                              lr_param.cgccpfnum,
                              lr_param.cgcord,
                              lr_param.cgccpfdig,
                              lr_param.funmat,
                              lr_param.ctttel,
                              lr_param.crtsaunum,
                              lr_param.bnfnum   ,
                              lr_param.ramgrpcod,
                              l_data_inicial,           #PSI234915
                              l_data_final)             #PSI234915

 #------------------------------------------------------
 # Busca ligacoes dos numeros das propostas da apolice
 #------------------------------------------------------
 call cta02m02_ligacoes_propostas(lr_param.succod
                                 ,lr_param.ramcod
                                 ,lr_param.aplnumdig)

 declare c_cta02m02_tmp cursor for
    select lignum, prpmrc, prporg, prpnumdig
      from cta02m02_tmp
    order by lignum desc

 let m_arr_aux = 1
 foreach c_cta02m02_tmp into am2_cta02m02[m_arr_aux].lignum, ---> Decreto - 6523
                             am_cta02m02[m_arr_aux].prpmrc,
                             am_cta02m02[m_arr_aux].prporg,
                             am_cta02m02[m_arr_aux].prpnumdig
    ##-- Obter informacoes da ligacao --##
    call cts20g03_dados_ligacao(1
                               ,am2_cta02m02[m_arr_aux].lignum)	--> Dec.- 6523
    returning lr_saida.resultado
             ,lr_saida.mensagem
             ,am_cta02m02[m_arr_aux].ligdat
             ,am_cta02m02[m_arr_aux].lighorinc
             ,mr_ws.funmat
             ,am_cta02m02[m_arr_aux].c24solnom
             ,l_c24soltipcod
             ,am_cta02m02[m_arr_aux].c24astcod
             ,am_cta02m02[m_arr_aux].c24paxnum

    if lr_saida.resultado <> 1 then
       if lr_saida.resultado <> 3 then
          let lr_saida.resultado = 1

          continue foreach
       else

          exit foreach
       end if
    end if

    #---> Decreto - 6523
    #---> Busca Número de Atendimento da Ligação.
    call ctd25g00_num_atend(am2_cta02m02[m_arr_aux].lignum)
         returning am_cta02m02[m_arr_aux].atdnum

    if  l_c24soltipcod = 2  or
        l_c24soltipcod = 8  then
       ##-- Obter o corretor --##
       call cts20g04_corretor_ligacao(am2_cta02m02[m_arr_aux].lignum)	---> Decreto - 6523
       returning lr_saida.resultado
                ,lr_saida.mensagem
                ,am_cta02m02[m_arr_aux].srvtxt
                ,am_cta02m02[m_arr_aux].atdetpdes
       if lr_saida.resultado = 3 then
          exit foreach
       end if
       let lr_saida.resultado = 1
    end if

    #---------------------------------------------------
    # Carrega tipo de solicitante
    #---------------------------------------------------
    if lr_param.apoio = "S" then
       let am_cta02m02[m_arr_aux].c24soltipdes = "Apoio"
    else
       ##-- Obter a descricao do tipo de solicitante --##
       call cto00m00_nome_solicitante(l_c24soltipcod
                                     ,'')
       returning lr_saida.resultado
                ,lr_saida.mensagem
                ,am_cta02m02[m_arr_aux].c24soltipdes

       if lr_saida.resultado = 3 then
          exit foreach
       end if
       let lr_saida.resultado = 1
    end if

   #----------------------------------------------------
   # Exibe servico relacionado a ligacao
   #----------------------------------------------------
    let mr_ws.atdsrvorg    = 0
    let mr_ws.drscrsagdcod = null

    call cts20g00_ligacao(am2_cta02m02[m_arr_aux].lignum)	---> Decreto - 6523
    returning am_cta02m02[m_arr_aux].atdsrvnum,
              am_cta02m02[m_arr_aux].atdsrvano,
              am_cta02m02[m_arr_aux].sinvstnum,
              am_cta02m02[m_arr_aux].sinvstano,
              am_cta02m02[m_arr_aux].ramcod,
              am_cta02m02[m_arr_aux].sinavsnum,
              am_cta02m02[m_arr_aux].sinavsano,
              am_cta02m02[m_arr_aux].sinnum,
              am_cta02m02[m_arr_aux].sinano,
              am_cta02m02[m_arr_aux].vstagnnum,
              mr_ws.trpavbnum,
              am_aux[m_arr_aux].cnslignum,
              mr_ws.crtsaunum,
              mr_ws.drscrsagdcod


    initialize  mr_ws.lclnumseq, mr_ws.rmerscseq to null

    ---> Obter a Sequencia do Local de Risco / Bloco do Condominio - RE
    ---> Informacoes somente para RE

    open  c_cta02m02_004 using am2_cta02m02[m_arr_aux].lignum
    fetch c_cta02m02_004  into mr_ws.lclnumseq
                           ,mr_ws.rmerscseq

    ---> Se o Docto Selecionado e a Ligacao tiver os dados da Seq.Local de Risco
    ---> ou o Bloco do Condominio despreza se nao forem iguais, porem se na
    ---> ligacao nao tiver estas informacoes mostra a ligacao para qualquer
    ---> Local de Risco ou Bloco
    if mr_ws.lclnumseq is not null and
       mr_ws.rmerscseq is not null then

       if mr_ws.lclnumseq <> g_documento.lclnumseq or
          mr_ws.rmerscseq <> g_documento.rmerscseq then
          initialize am2_cta02m02[m_arr_aux].lignum to null
	  continue foreach
       end if
    end if
    # Busca Valor Servico
    if am_cta02m02[m_arr_aux].atdsrvnum is not null and
       ( am_cta02m02[m_arr_aux].c24astcod <> 'CON'  and
         am_cta02m02[m_arr_aux].c24astcod <> 'REC'  and
         am_cta02m02[m_arr_aux].c24astcod <> 'ALT') then
       call cta02m02_contador_servico(am_cta02m02[m_arr_aux].atdsrvnum,
                                      am_cta02m02[m_arr_aux].atdsrvano)
            returning l_vlr_serv
       if l_vlr_serv is not null then
          let l_tot_serv = l_tot_serv + l_vlr_serv
          let l_qtd_serv = l_qtd_serv + 1
       end if
    end if

    if am_aux[m_arr_aux].cnslignum is not null then
       ##-- Obter o assunto da ligacao consultada --##
       call cts20g03_dados_ligacao(2
                                  ,am_aux[m_arr_aux].cnslignum)
       returning lr_saida.resultado
                ,lr_saida.mensagem
                ,l_c24astcod

       if lr_saida.resultado <> 1 then
          if lr_saida.resultado = 3 then
             exit foreach
          else
             let l_c24astcod = null
             let lr_saida.resultado = 1
          end if
       end if

       let l_aux = am_aux[m_arr_aux].cnslignum
       let am_cta02m02[m_arr_aux].srvtxt = l_aux clipped, "-", l_c24astcod clipped
    end if

    #----------------------------------------------------------
    # Verifica se codigo de assunto tem restricao de exibicao
    #----------------------------------------------------------
    if g_issk.acsnivcod  <  8   then
       initialize mr_ws.c24astexbflg  to null
       call cts25g00_dados_assunto(2
                                  ,am_cta02m02[m_arr_aux].c24astcod)
       returning lr_saida.resultado
                ,lr_saida.mensagem
                ,mr_ws.c24astexbflg

       if lr_saida.resultado = 3 then
          exit foreach
       end if
       let lr_saida.resultado = 1

       if mr_ws.c24astexbflg  =  "N"  and
          mr_ws.trpavbnum     is null and
          am_aux[m_arr_aux].cnslignum is null then
          continue foreach
       end if
    end if

    #--------------------------------------------------
    # Exibe situacao da reclamacao
    #--------------------------------------------------
    #PSI 230650 - inicio
    # Buscar codigo de agrupamento
    select c24astagp into l_c24astagp
          from datkassunto
         where c24astcod = am_cta02m02[m_arr_aux].c24astcod
    #PSI 230650 - fim

    if l_c24astagp                       = "W"   or
       l_c24astagp                       = "O"   or  # recl. cartao credito
       am_cta02m02[m_arr_aux].c24astcod  = "107" or  # PSS
       am_cta02m02[m_arr_aux].c24astcod  = "518" or  # PortoSeg
       am_cta02m02[m_arr_aux].c24astcod  = "K00" or
       am_cta02m02[m_arr_aux].c24astcod  = "I99" or
       am_cta02m02[m_arr_aux].c24astcod  = "P25" then # Itau

       ##-- Obter a situacao da reclamacao --##
       call cts20g03_sit_recl(1
                             ,am2_cta02m02[m_arr_aux].lignum)	---> Decreto - 6523
       returning lr_saida.resultado
                ,lr_saida.mensagem
                ,mr_ws.c24rclsitcod
       if lr_saida.resultado = 3 then
          exit foreach
       end if

       ##-- Obter a descricao da reclamacao --##
       call cty11g00_iddkdominio('c24rclsitcod'
                                ,mr_ws.c24rclsitcod)
       returning lr_saida.resultado
                ,lr_saida.mensagem
                ,am_cta02m02[m_arr_aux].atdetpdes

       if lr_saida.resultado = 3 then
          exit foreach
       end if

       ##-- Obter a reclamacao da ligacao --##
       call cts20g03_recl_ligacao(1
                                 ,am2_cta02m02[m_arr_aux].lignum)	---> Decreto - 6523
       returning lr_saida.resultado
                ,lr_saida.mensagem
                ,mr_ws.atdsrvnum_rcl
                ,mr_ws.atdsrvano_rcl

       if lr_saida.resultado = 3 then
          exit foreach
       end if

       if mr_ws.atdsrvnum_rcl is not null  then

          ##-- Obter origem e prestador do servico de reclamacao --##
          call cts10g06_dados_servicos(2
                                      ,mr_ws.atdsrvnum_rcl
                                      ,mr_ws.atdsrvano_rcl)
          returning lr_saida.resultado
                   ,lr_saida.mensagem
                   ,mr_ws.atdsrvorg_rcl
                   ,mr_ws.atdprscod

          if lr_saida.resultado = 3 then
             exit foreach
          end if
          let lr_saida.resultado = 1

          let am_cta02m02[m_arr_aux].srvtxt =
                         mr_ws.atdsrvorg_rcl  using "&&", "/",
                         mr_ws.atdsrvnum_rcl  using "&&&&&&&", "-",
                         mr_ws.atdsrvano_rcl  using "&&"
       end if
    end if

    if am_cta02m02[m_arr_aux].atdsrvnum is not null  and
       am_cta02m02[m_arr_aux].atdsrvano is not null  then

       ##-- Obter origem e prestador do servico --##
       call cts10g06_dados_servicos(2
                                   ,am_cta02m02[m_arr_aux].atdsrvnum
                                   ,am_cta02m02[m_arr_aux].atdsrvano)
       returning lr_saida.resultado
                ,lr_saida.mensagem
                ,mr_ws.atdsrvorg
                ,mr_ws.atdprscod

       if lr_saida.resultado = 3 then
          exit foreach
       end if
       let lr_saida.resultado = 1

       let am_cta02m02[m_arr_aux].srvtxt =
                       mr_ws.atdsrvorg  using "&&", "/",
                       am_cta02m02[m_arr_aux].atdsrvnum  using "&&&&&&&", "-",
                       am_cta02m02[m_arr_aux].atdsrvano  using "&&"

       ##-- Obter o ultima etapa do servico --##
       call cts10g04_ultima_etapa(am_cta02m02[m_arr_aux].atdsrvnum
                                 ,am_cta02m02[m_arr_aux].atdsrvano)
       returning mr_ws.atdetpcod

       ##-- Obter a descricao da etapa --##
       call cts10g05_desc_etapa(3, mr_ws.atdetpcod)
       returning lr_saida.resultado
                ,am_cta02m02[m_arr_aux].atdetpdes

       if lr_saida.resultado = 3 then
          let lr_saida.mensagem = 'Erro na descricao da etapa'
          exit foreach
       end if

       if mr_ws.atdsrvorg   =   14   then
          initialize mr_ws.etp to null
          if mr_ws.atdetpcod = 4 then
             let mr_ws.etp   = "Acion"
          else
            if mr_ws.atdetpcod = 5 then
               let mr_ws.etp = "Canc "
            end if
          end if
          if mr_ws.atdprscod  = 1    then   # carglass
             let am_cta02m02[m_arr_aux].atdetpdes = "Cargl/",mr_ws.etp
          else
             if mr_ws.atdprscod = 2 then    # abravauto
                let am_cta02m02[m_arr_aux].atdetpdes = "Abrav/",mr_ws.etp
             end if
          end if

          let am_cta02m02[m_arr_aux].sinvstnum = null
          let am_cta02m02[m_arr_aux].sinvstano = null

       end if
    end if

    #------------------------------------------------------------------
    # Verifica se JIT-RE e altera assunto de JIT para JRE
    #------------------------------------------------------------------
    if am_cta02m02[m_arr_aux].c24astcod = "JIT" then
       ##-- Obter o servico JIT --##
       call cts20g05_obter_srvjit(1
                                 ,am_cta02m02[m_arr_aux].atdsrvnum
                                 ,am_cta02m02[m_arr_aux].atdsrvano)
       returning lr_saida.resultado
                ,lr_saida.mensagem
                ,mr_ws.refatdsrvnum
                ,mr_ws.refatdsrvano

       if lr_saida.resultado = 3 then
          exit foreach
       end if

       let l_aux_ano4 = "20", mr_ws.refatdsrvano using "&&"

       ##-- if status <> notfound then --##
       if lr_saida.resultado = 1 then
          ##-- Obter a vistoria de sinistro --##
          call cts20g06_obter_vstsin(1
                                    ,mr_ws.refatdsrvnum
                                    ,l_aux_ano4)
          returning lr_saida.resultado
                   ,lr_saida.mensagem

          if lr_saida.resultado = 3 then
             exit foreach
          end if

          ##-- if status <> notfound then
          if lr_saida.resultado = 1 then

             ##-- Obter a ligacao do jit-re --##
             call cts20g03_vstsin_ligacao(mr_ws.refatdsrvnum
                                         ,l_aux_ano4)
             returning lr_saida.resultado
                      ,lr_saida.mensagem
                      ,mr_ws.lignumjre
             if lr_saida.resultado = 3 then
                exit foreach
             end if

             ##-- if status <> notfound then
             if lr_saida.resultado = 1 then

                ##-- Obter o assunto da ligacao de jit-re --##
                call cts20g03_dados_ligacao(2
                                           ,mr_ws.lignumjre)
                returning lr_saida.resultado
                         ,lr_saida.mensagem
                         ,mr_ws.c24astcodjre

                if lr_saida.resultado = 3 then
                   exit foreach
                end if

                if mr_ws.c24astcodjre = "V12" then
                   let am_cta02m02[m_arr_aux].c24astcod = "JRE"
                end if
             end if
          end if
       end if
    end if

    if am_cta02m02[m_arr_aux].sinvstnum is not null  and
       am_cta02m02[m_arr_aux].sinvstano is not null  and
       mr_ws.atdsrvorg                  <> 14        then

      #------------------------------------------------------------------
      # Verifica se V12 referente a JIT-RE e despreza
      #------------------------------------------------------------------
       if am_cta02m02[m_arr_aux].c24astcod = "V12" then
         let l_aux_char = am_cta02m02[m_arr_aux].sinvstano
         let l_aux_ano2 = l_aux_char[3,4]

         ##-- Obter o servico JIT --##
         call cts20g05_obter_srvjit(2
                                   ,am_cta02m02[m_arr_aux].atdsrvnum
                                   ,am_cta02m02[m_arr_aux].atdsrvano)
         returning lr_saida.resultado
                  ,lr_saida.mensagem

         if lr_saida.resultado = 3 then
            exit foreach
         end if

         if lr_saida.resultado = 1 then
            continue foreach
         end if
       end if

       let am_cta02m02[m_arr_aux].srvtxt =
           am_cta02m02[m_arr_aux].sinvstnum  using "&&&&&&", "-",
           am_cta02m02[m_arr_aux].sinvstano

       ##-- Verifica se vistoria de sinistro esta cancelada --##
       call cts20g07_canc_vstsin(1
                                ,am_cta02m02[m_arr_aux].sinvstnum
                                ,am_cta02m02[m_arr_aux].sinvstano)
       returning lr_saida.resultado
                ,lr_saida.mensagem
                ,l_canmtvdes

       if lr_saida.resultado = 3 then
          exit foreach
       end if

       if lr_saida.resultado = 1 then
          let am_cta02m02[m_arr_aux].atdetpdes = "CANCELADA"
       end if
    end if

    if am_cta02m02[m_arr_aux].sinavsnum is not null  and
       am_cta02m02[m_arr_aux].sinavsano is not null  then
       let am_cta02m02[m_arr_aux].srvtxt =
           am_cta02m02[m_arr_aux].sinavsnum  using "&&&&&&", "-",
           am_cta02m02[m_arr_aux].sinavsano
    end if

    if am_cta02m02[m_arr_aux].sinnum is not null  and
       am_cta02m02[m_arr_aux].sinano is not null  then

       ##-- Obter o flag de pendencia --##
       call cts20g03_sin_ligacao(1,am2_cta02m02[m_arr_aux].lignum)	---> Decreto - 6523
       returning lr_saida.resultado
                ,lr_saida.mensagem
                ,mr_ws.ligsinpndflg

       if lr_saida.resultado = 3 then
          exit foreach
       end if

       if lr_saida.resultado = 1 then
          if  mr_ws.ligsinpndflg = "S" then
              let mr_ws.pnd = "P"
          else
              let mr_ws.pnd = " "
          end if
       else
          let mr_ws.pnd = " "
       end if

       let am_cta02m02[m_arr_aux].srvtxt =
                     am_cta02m02[m_arr_aux].sinnum  using "&&&&&&", "-",
                     am_cta02m02[m_arr_aux].sinano, mr_ws.pnd
    end if

    if am_cta02m02[m_arr_aux].vstagnnum is not null then

       ##-- Obter o numero e situacao do agendamento de vistoria --##
       call cts20g03_agn_ligacao(am2_cta02m02[m_arr_aux].lignum)	---> Decreto - 6523
       returning lr_saida.resultado
                ,lr_saida.mensagem
                ,mr_ws.vstagnnum
                ,mr_ws.vstagnstt

       if lr_saida.resultado = 3 then
          exit foreach
       end if

       let am_cta02m02[m_arr_aux].srvtxt = mr_ws.vstagnnum using "&&&&&&&"

       #verifica se o agendamento e do sistema novo(web)
       select agncod
          from avgmagn
         where agncod = mr_ws.vstagnnum
       if sqlca.sqlcode = 0 then
          case mr_ws.vstagnstt
             when("A")
                let am_cta02m02[m_arr_aux].atdetpdes = "AGEN/CANC"
             when("C")
                let am_cta02m02[m_arr_aux].atdetpdes = "CANCELADO"
             when("I")
                let am_cta02m02[m_arr_aux].atdetpdes = "AGENDADO"
             otherwise
                let am_cta02m02[m_arr_aux].atdetpdes = "INVALIDO"
          end case
       else
          if mr_ws.vstagnstt = "C"   then
             let am_cta02m02[m_arr_aux].atdetpdes = "CANCELADA"
          else
             let am_cta02m02[m_arr_aux].atdetpdes = "AGENDADO"
          end if
       end if
    end if

    ---> Status/Nro. Agendamento do Curso de Direcao Defensiva
    if mr_ws.drscrsagdcod is not null then

       call cts20g03_agn_ligacao(am2_cta02m02[m_arr_aux].lignum)-->Decreto-6523
       returning lr_saida.resultado
                ,lr_saida.mensagem
                ,mr_ws.drscrsagdcod
                ,mr_ws.vstagnstt

       if lr_saida.resultado = 3 then
          exit foreach
       end if

       let am_cta02m02[m_arr_aux].srvtxt = mr_ws.drscrsagdcod using "&&&&&&&"
       if mr_ws.vstagnstt = "C"   then
          let am_cta02m02[m_arr_aux].atdetpdes = "CANCELADO"
       else
          let am_cta02m02[m_arr_aux].atdetpdes = "AGENDADO"
       end if
    end if

    if mr_ws.trpavbnum is not null then
       let am_cta02m02[m_arr_aux].srvtxt    = mr_ws.trpavbnum using "&&&&&&"
       let am_cta02m02[m_arr_aux].atdetpdes = "AVERBACAO"
    end if
    #---------------------------------------------------------------------
    # Nome do atendente
    #---------------------------------------------------------------------
    let am_cta02m02[m_arr_aux].funnom = "NAO CADASTR."
    let m_c24usrtip = null
    let m_c24empcod = null

    ##-- Obter o nome do funcionario --##
    if mr_ws.funmat = 999999 or mr_ws.funmat = 0 then
       let am_cta02m02[m_arr_aux].funnom = "PORTAL"
    else
       open c_cta02m02_003 using am2_cta02m02[m_arr_aux].lignum	---> Decreto - 6523
       fetch c_cta02m02_003 into m_c24usrtip, m_c24empcod
       close c_cta02m02_003

       # ALTERAÇÃO BURINI
       # Em algumas ligações antigas esses campos estão nulo.
       if  m_c24usrtip is null then
           let m_c24usrtip = 'F'
       end if

       if  m_c24empcod is null then
           let m_c24empcod = 1
       end if
       # FINAL ALTERACAO BURINI

       call cty08g00_nome_func(m_c24empcod,
                               mr_ws.funmat,
                               m_c24usrtip)

       returning lr_saida.resultado
                ,lr_saida.mensagem
                ,am_cta02m02[m_arr_aux].funnom

       if lr_saida.resultado = 3 then
          exit foreach
       end if

    end if

    let am_cta02m02[m_arr_aux].funnom = upshift(am_cta02m02[m_arr_aux].funnom)

    #---------------------------------------------------------------------
    # Verifica se houve envio de mensagem para corretor
    #---------------------------------------------------------------------
    let am_cta02m02[m_arr_aux].msgenv = null

    call cts20g03_msg_ligacao(am2_cta02m02[m_arr_aux].lignum)	---> Decreto - 6523
    returning lr_saida.resultado
             ,lr_saida.mensagem
            ,l_mstnum

    if lr_saida.resultado = 3 then
       exit foreach
    end if

    if lr_saida.resultado = 1 then
       let am_cta02m02[m_arr_aux].msgenv = "S"
    end if

    let lr_saida.resultado = 1

    #---------------------------------------------------------------------
    # Monta descricao do assunto
    #---------------------------------------------------------------------
    if am_cta02m02[m_arr_aux].c24astcod = "JRE" then
       let am_cta02m02[m_arr_aux].c24astcod = "JIT"
       let am_cta02m02[m_arr_aux].c24astdes = c24geral8(am_cta02m02[m_arr_aux].c24astcod)
       let am_cta02m02[m_arr_aux].c24astcod = "JRE"
    else
       let am_cta02m02[m_arr_aux].c24astdes = c24geral8(am_cta02m02[m_arr_aux].c24astcod)
    end if

    call cts20g14_motivo_con(am2_cta02m02[m_arr_aux].lignum)	---> Decreto - 6523
    returning lr_cts20g14_motivo_con.resultado,
              lr_cts20g14_motivo_con.mensagem,
              l_rcuccsmtvcod,
              l_assunto

    if l_rcuccsmtvcod is not null  and
       l_rcuccsmtvcod <> 0         and
       g_documento.ciaempcod <> 27 then
       let l_astcod = '*', am_cta02m02[m_arr_aux].c24astcod clipped
       let am_cta02m02[m_arr_aux].c24astcod = l_astcod
    end if                                               #PSI180475 - robson - fim

    if am_cta02m02[m_arr_aux].c24astcod = "O**" and
       l_acesso                         = 0     and
       lr_param.nivel_retorno           = 2     then
         let l_confirma = cts08g01("A","N","Antes de Qualquer Providencia",
                                   "Verifique as Ligacoes ",
                                   " pois foi Encontrado Registro de  " ,
                                   "ADVERTENCIA")
       let l_acesso = l_acesso + 1
    end if
    #---> Decreto - 6523

    if m_arr_aux = 1 then
       whenever error continue
       delete from cta02m00_tmp_ligacoes
       whenever error stop
    end if

    whenever error continue
    insert into cta02m00_tmp_ligacoes values (am2_cta02m02[m_arr_aux].lignum
                                             ,am_cta02m02[m_arr_aux].c24astcod
                                             ,am_cta02m02[m_arr_aux].c24astdes
                                             ,am_cta02m02[m_arr_aux].ligdat
                                             ,am_cta02m02[m_arr_aux].lighorinc)
    whenever error stop

    let m_arr_aux = m_arr_aux + 1

    let lr_saida.resultado = 1

    if m_arr_aux > 500 then
       error " Limite excedido. Consulta com mais de 500 ligacoes!"
       exit foreach
    end if

 end foreach

 if m_arr_aux = 1 then
    initialize am_cta02m02[1].* to null
 end if

 close c_cta02m02_tmp

 if lr_saida.resultado <> 3 then
    let lr_saida.resultado =  1
 end if

 if lr_param.nivel_retorno = 1 then
    return lr_saida.*
 end if

 if lr_param.nivel_retorno = 2 then
    return lr_saida.*,
           am_cta02m02[1].*,
           am_cta02m02[2].*,
           am_cta02m02[3].*,
           l_qtd_serv,
           l_tot_serv
 end if

end function

#-----------------------------------------#
function cta02m02_obter_ligacoes(lr_param, l_dataini, l_datafim)  #PSI234915
#-----------------------------------------#
 define lr_param record
    apoio     char(01)
   ,empcodatd like datmligatd.apoemp
   ,funmatatd like datmligatd.apomat
   ,succod    like datrligapol.succod
   ,ramcod    like datrligapol.ramcod
   ,aplnumdig like datrligapol.aplnumdig
   ,itmnumdig like datrligapol.itmnumdig
   ,prporg    like datrligprp.prporg
   ,prpnumdig like datrligprp.prpnumdig
   ,fcapacorg like datrligpac.fcapacorg
   ,fcapacnum like datrligpac.fcapacnum
   ,cmnnumdig like pptmcmn.cmnnumdig
   ,corsus    like datrligcor.corsus
   ,cgccpfnum like gsakseg.cgccpfnum
   ,cgcord    like gsakseg.cgcord
   ,cgccpfdig like gsakseg.cgccpfdig
   ,funmat    like datmligacao.c24funmat
   ,ctttel    like datmreclam.ctttel
   ,crtsaunum like datksegsau.crtsaunum
   ,bnfnum    like datksegsau.bnfnum
   ,ramgrpcod like gtakram.ramgrpcod
 end record

 define l_dataini  date,       #PSI234915
        l_datafim  date        #PSI234915

 define l_lignum decimal(10,0)

 define lr_cty22g00 record
 	     cont integer        ,
 	     sucursais char(100)
 end record
 let l_lignum = null
 initialize lr_cty22g00.* to null
 let lr_cty22g00.cont   = false

 while true

         # Bloco 1
         if lr_param.apoio = "S" and
            lr_param.aplnumdig is null and
            lr_param.prpnumdig is null and
            lr_param.fcapacnum is null then
            open c_cta02m02 using lr_param.empcodatd,
                                  lr_param.funmatatd
           exit while
         end if


         # Bloco 2
         if lr_param.succod is not null  and
            lr_param.ramcod is not null  and
            lr_param.aplnumdig is not null then
            if lr_param.ramgrpcod = 5 then
               open c_cta02m02 using lr_param.bnfnum
               exit while
            else
               if g_documento.ciaempcod = 84 then # Itau

                  call cty22g00_rec_sucursal_itau(g_documento.itaciacod,
                                                  lr_param.succod      ,
                                                  lr_param.ramcod      ,
                                                  lr_param.aplnumdig   ,
                                                  lr_param.itmnumdig   )
                  returning lr_cty22g00.cont ,
                            lr_cty22g00.sucursais
                  if lr_cty22g00.cont then
                     open c_cta02m02 using
                                           lr_param.ramcod     ,
                                           lr_param.aplnumdig  ,
                                           lr_param.itmnumdig  ,
                                           g_documento.itaciacod
                  else
                     open c_cta02m02 using lr_param.succod     ,
                                           lr_param.ramcod     ,
                                           lr_param.aplnumdig  ,
                                           lr_param.itmnumdig  ,
                                           g_documento.itaciacod
                  end if

                  exit while
               else
                   open c_cta02m02 using lr_param.succod   ,
                                         lr_param.ramcod   ,
                                         lr_param.aplnumdig,
                                         lr_param.itmnumdig
                   exit while
               end if
            end if
         end if

         # Bloco 3
         if g_pss.psscntcod is not null  then # PSS     
            display "g_pss.psscntcod: ", g_pss.psscntcod
            open c_cta02m02 using g_pss.psscntcod
            exit while
         end if


         # Bloco 4
        if lr_param.prporg    is not null  and
            lr_param.prpnumdig is not null  then
            open c_cta02m02 using lr_param.prporg,
                                  lr_param.prpnumdig
            exit while
         end if


         # Bloco 5
         if lr_param.fcapacorg is not null  and
            lr_param.fcapacnum is not null  then
            open c_cta02m02 using lr_param.fcapacorg,
                                  lr_param.fcapacnum
            exit while
         end if


         # Bloco 6
         if lr_param.cmnnumdig is not null then
            open c_cta02m02 using lr_param.cmnnumdig
            exit while
         end if


         # Bloco 7
         if lr_param.corsus is not null then
            #PSI 234915 - se periodo foi informado busca ligacoes dentro do periodo
            # senão busca todas as ligacoes, mantendo a regra que existe hoje
            if l_dataini is not null and
               l_datafim is not null then
               open c_cta02m02 using lr_param.corsus,
                                     l_dataini,
                                     l_datafim
            else
               open c_cta02m02 using lr_param.corsus
            end if
            exit while
         end if


         # Bloco 8
         if lr_param.cgccpfnum is not null then
            open c_cta02m02 using lr_param.cgccpfnum,lr_param.cgcord,lr_param.cgccpfdig
            exit while
         end if


         # Bloco 9
         if lr_param.funmat is not null then
            #PSI - se periodo foi informado busca ligacoes dentro do periodo
            # senão busca todas as ligacoes, mantendo a regra que existe hoje
            if l_dataini is not null and
               l_datafim is not null then
               open c_cta02m02 using lr_param.funmat,
                                     l_dataini,
                                     l_datafim
            else
              open c_cta02m02 using lr_param.funmat
            end if
            exit while
         end if


         # Bloco 10
         if lr_param.ctttel is not null then
            open c_cta02m02 using lr_param.ctttel
         exit while
         end if


         # Bloco 11
         if g_cgccpf.ligdctnum is not null and
            g_cgccpf.ligdcttip is not null then
                open c_cta02m02 using g_cgccpf.ligdctnum ,
                                      g_cgccpf.ligdcttip
            exit while
         end if

         exit while

  end while

 foreach c_cta02m02 into l_lignum
    insert into cta02m02_tmp
       values ( l_lignum, " ", 0, 0 )
 end foreach

end function


#PSI 234915 - funcao para informar periodo de busca de ligacoes quando for
# informado SUSEP sem docto
#=======================================#
function cta02m02_informa_filtro_susep(lr_param)
#=======================================#

   define lr_param  record
          corsus    like datrligcor.corsus,
          funmat    like datmligacao.c24funmat
   end record

   define l_cabtxt char(20)

   define lr_periodo    record
          dtini       date,
          dtfim       date
   end record

  initialize  lr_periodo.*  to  null

  open window w_cta02m02a at 10,22 with form "cta02m02a"
    attribute(border, form line 1)

  #para pesquisar todas as ligacoes independente da data
  # sair da tela de periodo com ctrl+c

  if lr_param.corsus is not null then
     let l_cabtxt = "CORRETOR"
     display  l_cabtxt  to  cab
  else
     let l_cabtxt = "MATRICULA"
     display  l_cabtxt  to  cab
  end if


  input by name lr_periodo.* without defaults

    before field dtini
           display by name lr_periodo.dtini attribute (reverse)

    after  field dtini
           display by name lr_periodo.dtini
           if lr_periodo.dtini is null then
              error " Data inicial do periodo deve ser informada!"
              next field dtini
           end if

    before field dtfim
           display by name lr_periodo.dtfim attribute (reverse)

    after  field dtfim
           display by name lr_periodo.dtfim

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              next field dtini
           end if
           if lr_periodo.dtfim is null then
              error " Data final do periodo deve ser informada!"
              next field dtfim
           end if
           if lr_periodo.dtfim < lr_periodo.dtini then
              error " Data final nao pode ser menor que data inicial!"
              next field dtfim
           end if

  end input

  close window w_cta02m02a

  let int_flag = false

  return lr_periodo.dtini,
         lr_periodo.dtfim

end function


#---------------------------------------------#
function cta02m02_ligacoes_propostas(lr_param)
#---------------------------------------------#
 define lr_param record
    succod    decimal(2,0)
   ,ramcod    smallint
   ,aplnumdig decimal(9,0)
 end record

 define lr_aux record
    prporg    decimal(2,0)
   ,prpnumdig decimal(8,0)
   ,lignum    decimal(10,0)
 end record

 define l_sql_comando char(300)

 initialize lr_aux to null

 if lr_param.succod is not null  and
    lr_param.ramcod is not null  and
    lr_param.aplnumdig is not null  then
    if lr_param.ramcod = 31  or
       lr_param.ramcod = 531 then  # AUTO
       let l_sql_comando = "select prporgpcp,   ",
                         "       prpnumpcp    ",
                         "  from abamdoc      ",
                         " where abamdoc.succod    = ", lr_param.succod   ,
                         "   and abamdoc.aplnumdig = ", lr_param.aplnumdig
    else                       # R.E.
       let l_sql_comando = "select sgrorg,      ",
                         "       sgrnumdig    ",
                         "  from rsamseguro   ",
                         " where succod    = ", lr_param.succod  ,
                         "   and ramcod    =",  lr_param.ramcod  ,
                         "   and aplnumdig =",  lr_param.aplnumdig
    end if
    prepare p_cta02m02_005 from l_sql_comando
    declare c_cta02m02_005 cursor for p_cta02m02_005

    foreach c_cta02m02_005 into lr_aux.prporg,
                             lr_aux.prpnumdig
       declare c_cta02m02_006 cursor for
          select lignum
            from datrligprp
           where prporg    = lr_aux.prporg
             and prpnumdig = lr_aux.prpnumdig
       foreach c_cta02m02_006 into lr_aux.lignum
          insert into cta02m02_tmp
                 values ( lr_aux.lignum, "*", lr_aux.prporg, lr_aux.prpnumdig )
       end foreach
    end foreach
 end if

end function

#CT - 604380 inicio #
#---------------------------------------------------#
function cta02m02_recarrega_globais(param)
#---------------------------------------------------#


    define param record
            succod    like datrligapol.succod
           ,ramcod    like datrligapol.ramcod
           ,aplnumdig like datrligapol.aplnumdig
           ,itmnumdig like datrligapol.itmnumdig
           ,prporg    like datrligprp.prporg
           ,prpnumdig like datrligprp.prpnumdig
    end record

    let g_documento.succod    =  param.succod
    let g_documento.ramcod    =  param.ramcod
    let g_documento.aplnumdig =  param.aplnumdig
    let g_documento.itmnumdig =  param.itmnumdig
    let g_documento.prporg    =  param.prporg
    let g_documento.prpnumdig =  param.prpnumdig

end function # end recarrega_globais
#CT - 604380 Fim #

function cta02m02_contador_servico(lr_param)

    define lr_param record
       atdsrvnum like datmservico.atdsrvnum,
       atdsrvano like datmservico.atdsrvano
    end record

    define lr_retorno record
           coderro smallint,
           mens    char(400),
           vlr_serv integer
    end record
    initialize lr_retorno.* to null
    if m_prep is null or
       m_prep = false then
       call cta02m02_prep()
    end if
    whenever error continue
    open ccta02m0205 using lr_param.atdsrvnum,
                           lr_param.atdsrvano
    fetch ccta02m0205 into lr_retorno.vlr_serv
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode <> 100 then
          let lr_retorno.coderro = sqlca.sqlcode
          let lr_retorno.mens = 'Erro < ',lr_retorno.coderro clipped ,' > ao buscar servico pago'
          call errorlog(lr_retorno.mens)
       end if
    end if
 return lr_retorno.vlr_serv
end function
