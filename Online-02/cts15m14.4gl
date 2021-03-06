#.............................................................................#
# Sistema........: Porto Socorro                                              #
# Modulo.........: cts15m14                                                   #
# Objetivo.......: Montar laudo de reserva para  ImpressAo, fax ou Internet   #
# Analista Resp. : Ligia Mattge                                               #
# PSI            : 196878                                                     #
#.............................................................................#
# Desenvolvimento: Andrei, META                                               #
# Liberacao      : 24/02/2006                                                 #
#.............................................................................#
#                  * * *  ALTERACOES  * * *                                   #
#                                                                             #
# Data       Autor Fabrica PSI       Alteracao                                #
#-----------------------------------------------------------------------------#
# 30/10/2009 Carla Rampazzo             Tratar novas clausulas do Carro Extra #
#                                       Livre Escolha: 58E-05dias / 58F-10dias#
#                                                      58G-15dias / 58H-30dias#
#-----------------------------------------------------------------------------#
# 10/12/2009 Amilton, Meta   PSI251429  Trocar a mensagem para o motivo 3,6   #
#                                       e assunto H12 e H13 PAS               #
#-----------------------------------------------------------------------------#
# 15/07/2010 Carla Rampazzo             Tratar novas clausulas do Carro Extra #
#                                       Referenciada : 58I -  7 dias          #
#                                                      58J - 15 dias          #
#                                                      58K - 15 dias          #
#                                                                             #
#                                       Livre Escolha: 58L -  7 dias          #
#                                                      58M - 15 dias          #
#                                                      58N - 15 dias          #
#-----------------------------------------------------------------------------#
# 07/05/2012 Silvia, Meta PSI-2012-07408/PR  Projeto Anatel - DDD / TEl       #
#-----------------------------------------------------------------------------#
# 27/12/2012 Luiz, BRQ PSI-2012-26565/EV  Altera��o � criar um link concate-  #
#                                         nar os atributos localizados no ban-#
#                                         co de dados referente ao Servi�o/Lo-#
#                                         cadora a fim de sensibilizar o res- #
#                                         pons�vel na loja da Locadora que    #
#                                         existe uma reserva pendente para    #
#                                         resposta                            #
#-----------------------------------------------------------------------------#
# 10/07/2013 Gabriel, Fornax P13070041   Inclusao da variavel                 #
#                                         lr_param.avialgmtv na chamada da    #
#                                         funcao ctx01g01_claus_novo          #
#-----------------------------------------------------------------------------#
# 29/07/2013 Fabio, Fornax PSI-2013-06224/PR                                  #
#                          Identificacao no Acionamento do Laudo empresa SAPS #
#-----------------------------------------------------------------------------#
# 03/09/2013 Issamu                      inclus�o da chamada do fax via       #
#                                        right fa                             #
#                                                                             #
#                                                                             #
#-----------------------------------------------------------------------------#
# 15/07/2014 Rodolfo                      Retirada da funcao de envio envio   #
#                                         de FAX VSI que ocasionava lentidao  #
#                                         e correcao da chamada do RightFax   #
#                                                                             #
###############################################################################
globals "/homedsa/projetos/geral/globals/glct.4gl"



# Inicio Altera��o - Fabrica BRQ - Luiz Gustavo - PSI-2012-26565/EV

globals "/homedsa/projetos/geral/globals/figrc012.4gl"

 define m_acntip like datklocadora.acntip
       ,m_texto char(32000)

# Fim Altera��o - Fabrica BRQ - Luiz Gustavo - PSI-2012-26565/EV

 define m_arquivo char(100)
 define wsgpipe char(80)
 define m_ciaempcod like datmservico.ciaempcod
  define m_cts15m14_prep smallint
 define m_atdetpcod like datmsrvacp.atdetpcod
 define m_usuario  char(15)

 define am_cts36g01 array[50] of record
                                 resultado    smallint
                                ,mensagem     char(100)
                                ,vclretdat    like datmprorrog.vclretdat
                                ,vclrethor    like datmprorrog.vclrethor
                                ,aviprodiaqtd like datmprorrog.aviprodiaqtd
                                ,aviprosoldat like datmprorrog.aviprosoldat
                                ,aviprosolhor like datmprorrog.aviprosolhor
                                ,aviprostt    like datmprorrog.aviprostt
                            end record

 define lr_retorno record
    resultado    smallint
   ,mensagem     char(60)
   ,c24astcod    like datmligacao.c24astcod
 end record

function cts15m14_prepare()

  define l_sql char(1000)

  let l_sql = "select c24astcod  ",
              " from   datmligacao " ,
              " where  lignum = ? "
  prepare pcts15m14001 from l_sql
  declare ccts15m14001 cursor for pcts15m14001


  let l_sql = "select sum(rsrutidiaqtd) ",
              " from datrvcllocrsrcmp ",
              " where atdsrvnum =? ",
              " and atdsrvano =  ? "
  prepare pcts15m14002 from l_sql
  declare ccts15m14002 cursor for pcts15m14002

# Inicio Altera��o - Fabrica BRQ - Luiz Gustavo - PSI-2012-26565/EV

  let l_sql = "select t1.atdetpdat,                                               ",
              "       t1.atdetphor,                                               ",
              "       t1.atdsrvseq as atdsrvseq,                                  ",
              "       t1.atdetpcod                                                ",
              "from datmsrvacp as t1                                              ",
              "where t1.atdsrvnum  = ?                                            ",
              "and   t1.atdsrvano  = ?                                            ",
              "and t1.atdsrvseq = (select max(t2.atdsrvseq)  from datmsrvacp as t2",
              "                   where t2.atdsrvnum  = t1.atdsrvnum              ",
              "                   and   t2.atdsrvano  = t1.atdsrvano)             "
  prepare pcts15m14003 from l_sql
  declare ccts15m14003 cursor for pcts15m14003

  let l_sql = "select grlinf ",
              "from datkgeral ",
              "where grlchv = 'PSOLOCTMPEXP'"
  prepare pcts15m14004 from l_sql
  declare ccts15m14004 cursor for pcts15m14004

  let l_sql = "select acntip ",
              "from datklocadora ",
              "where lcvcod = ? "
  prepare pcts15m14005 from l_sql
  declare ccts15m14005 cursor for pcts15m14005
 
 # Fim Altera��o - Fabrica BRQ - Luiz Gustavo - PSI-2012-26565/EV
  
  let l_sql =  " select  smsenvdddnum    "
              ,"        ,smsenvcelnum    "
              ,"        ,cttdddcod    "
              ,"        ,ctttelnum       "
              ,"    from datmavisrent     "
              ,"   where atdsrvnum = ?   "
              ,"     and atdsrvano = ?   "
  prepare pcts15m14006 from l_sql
  declare ccts15m14006 cursor for pcts15m14006
  
  
  let m_cts15m14_prep = true

end function


#---------------------------------------
function cts15m14_carro_extra(lr_param)
#---------------------------------------

 define lr_param record
                 atdsrvnum like datmservico.atdsrvnum
                ,atdsrvano like datmservico.atdsrvano
                ,dddcod    like datklocadora.dddcod
                ,facnum    like datklocadora.facnum
                ,faxch1    like datmfax.faxch1
                ,faxch2    like datmfax.faxch2
                ,destino   char(024)
                ,enviar    char(001)
                ,msg1      char(050)
                ,msg2      char(050)
                ,execucao  char(080)
                ,clscod    char(003)
                ,acao      char(001)
             end record

 define lr_ret record
               resultado smallint
              ,mensagem  char(100)
           end record

 define lr_cts10g06 record
                    atdsrvorg like datmservico.atdsrvorg
                   ,atddat    like datmservico.atddat
                   ,atdhor    like datmservico.atdhor
                   ,nom       like datmservico.nom
                   ,atdfnlflg like datmservico.atdfnlflg
                end record

 define lr_cts36g00 record
                    lcvcod       like datmavisrent.lcvcod
                   ,avivclcod    like datmavisrent.avivclcod
                   ,avivclvlr    like datmavisrent.avivclvlr
                   ,locsegvlr    like datmavisrent.locsegvlr
                   ,avilocnom    like datmavisrent.avilocnom
                   ,avidiaqtd    like datmavisrent.avidiaqtd
                   ,aviestcod    like datmavisrent.aviestcod
                   ,aviretdat    like datmavisrent.aviretdat
                   ,avirethor    like datmavisrent.avirethor
                   ,aviprvent    like datmavisrent.aviprvent
                   ,avialgmtv    like datmavisrent.avialgmtv
                   ,avioccdat    like datmavisrent.avioccdat
                   ,avirsrgrttip like datmavisrent.avirsrgrttip
                   ,cdtoutflg    like datmavisrent.cdtoutflg
                   ,locrspcpfnum like datmavisrent.locrspcpfnum
                   ,locrspcpfdig like datmavisrent.locrspcpfdig
                end record

 define lr_cts20g03 record
                    c24soltipcod like datksoltip.c24soltipcod
                   ,c24solnom    like datksoltip.c24soltipdes
                end record

 define lr_ctc17g00 record
                    avivclmdl like datkavisveic.avivclmdl
                   ,avivcldes like datkavisveic.avivcldes
                   ,avivclgrp like datkavisveic.avivclgrp
                end record

 define lr_ctc18g00 record
                    lcvextcod     like datkavislocal.lcvextcod
                   ,aviestnom     like datkavislocal.aviestnom
                   ,lcvregprccod  like datkavislocal.lcvregprccod
                end record

 define lr_cts36g01 record
                    vclretdat    like datmprorrog.vclretdat
                   ,vclrethor    like datmprorrog.vclrethor
                   ,aviprodiaqtd like datmprorrog.aviprodiaqtd
                   ,aviprosoldat like datmprorrog.aviprosoldat
                   ,aviprosolhor like datmprorrog.aviprosolhor
                   ,aviprostt    like datmprorrog.aviprostt
                end record

 define l_ligacao      like datmligacao.lignum
       ,l_c24soltipdes like datksoltip.c24soltipdes
       ,l_adcsgrtaxvlr like datklocadora.adcsgrtaxvlr
       ,l_descricao_veiculo char(100)

 define l_saldo     char(100)
       ,l_condicao  char(100)
       ,l_path      char(100)
       ,l_impressao char(150)
       ,l_cont      smallint
       ,l_resultado smallint
       ,l_mensagem  char(50)
       ,l_grlinf    like datkgeral.grlinf

# Inicio Altera��o - Fabrica BRQ - Luiz Gustavo - PSI-2012-26565/EV

   define l_result datetime hour to minute

   initialize l_result to null

   let m_acntip = 0

   if not figrc012_sitename("cts15m14","","") then
      display "Hostname nao encontrado!" sleep 5
   end if

# Fim Altera��o - Fabrica BRQ - Luiz Gustavo - PSI-2012-26565/EV

 initialize lr_ret      to null
 initialize lr_cts10g06 to null
 initialize lr_cts36g00 to null
 initialize lr_cts20g03 to null
 initialize lr_ctc17g00 to null
 initialize lr_ctc18g00 to null
 initialize am_cts36g01 to null

 let wsgpipe      = lr_param.execucao
 let l_ligacao      = null
 let l_c24soltipdes = null
 let l_adcsgrtaxvlr = null
 let l_descricao_veiculo = null
 let l_saldo    = null
 let l_condicao = null
 let l_impressao = null
 let l_cont = 1
 let m_arquivo = null
 let l_resultado = null
 let l_mensagem  = null

 let l_path = f_path('ONLTEL', 'RELATO')
 if l_path is null or l_path = ' ' then
    let l_path = '.'
 end if

 select ciaempcod
    into m_ciaempcod
    from datmservico
   where atdsrvnum =  lr_param.atdsrvnum
     and atdsrvano =  lr_param.atdsrvano

 let m_arquivo = null

 call cts10g06_dados_servicos( 5, lr_param.atdsrvnum, lr_param.atdsrvano)
    returning lr_ret.resultado
             ,lr_ret.mensagem
             ,lr_cts10g06.atdsrvorg
             ,lr_cts10g06.atddat
             ,lr_cts10g06.atdhor
             ,lr_cts10g06.nom
             ,lr_cts10g06.atdfnlflg

 if lr_ret.resultado <> 1 then
    error lr_ret.mensagem
    return
 end if

 call cts36g00_dados_locacao(1,lr_param.atdsrvnum, lr_param.atdsrvano)
    returning lr_ret.resultado
             ,lr_ret.mensagem
             ,lr_cts36g00.lcvcod
             ,lr_cts36g00.avivclcod
             ,lr_cts36g00.avivclvlr
             ,lr_cts36g00.locsegvlr
             ,lr_cts36g00.avilocnom
             ,lr_cts36g00.avidiaqtd
             ,lr_cts36g00.aviestcod
             ,lr_cts36g00.aviretdat
             ,lr_cts36g00.avirethor
             ,lr_cts36g00.aviprvent
             ,lr_cts36g00.avialgmtv
             ,lr_cts36g00.avioccdat
             ,lr_cts36g00.avirsrgrttip
             ,lr_cts36g00.cdtoutflg
             ,lr_cts36g00.locrspcpfnum
             ,lr_cts36g00.locrspcpfdig


 if lr_ret.resultado <> 1 then
    error lr_ret.mensagem
    return
 end if

 let l_ligacao =  cts20g00_servico(lr_param.atdsrvnum, lr_param.atdsrvano)

 if l_ligacao is null then
     error "Ligacao nao encontrada"
     return
 end if

 call cts20g03_dados_ligacao(3, l_ligacao )
    returning lr_ret.resultado
             ,lr_ret.mensagem
             ,lr_cts20g03.c24soltipcod
             ,lr_cts20g03.c24solnom

 if lr_ret.resultado <> 1 then
    error lr_ret.mensagem
    return
 end if

 call cto00m00_nome_solicitante(lr_cts20g03.c24soltipcod, '')
    returning lr_ret.resultado
             ,lr_ret.mensagem
             ,l_c24soltipdes

 if lr_ret.resultado <> 1 then
    error lr_ret.mensagem
    return
 end if

 call ctc17g00_dados_veic(1, lr_cts36g00.lcvcod, lr_cts36g00.avivclcod)
    returning lr_ret.resultado
             ,lr_ret.mensagem
             ,lr_ctc17g00.avivclmdl
             ,lr_ctc17g00.avivcldes
             ,lr_ctc17g00.avivclgrp

 if lr_ret.resultado <> 1 then
    error lr_ret.mensagem
    return
 end if

 if lr_ctc17g00.avivclgrp = 'A' then
    let l_descricao_veiculo  =  'BASICO ', lr_ctc17g00.avivcldes
 else
    let l_descricao_veiculo  = lr_ctc17g00.avivclmdl clipped  , ' ', lr_ctc17g00.avivcldes
 end if

 if g_documento.ciaempcod = 84 then
 call cts15m14_saldo_condicao_itau(lr_param.atdsrvnum
                                  ,lr_param.atdsrvano
                                  ,lr_param.clscod
                                  ,lr_ctc17g00.avivclgrp
                                  ,lr_cts36g00.avialgmtv
                                  ,lr_cts36g00.avioccdat
                                  ,lr_cts36g00.lcvcod
                                  ,lr_cts10g06.atdfnlflg)

    returning l_saldo
             ,l_condicao
 else
 call cts15m14_saldo_condicao(lr_param.atdsrvnum
                             ,lr_param.atdsrvano
                             ,lr_param.clscod
                             ,lr_ctc17g00.avivclgrp
                             ,lr_cts36g00.avialgmtv
                             ,lr_cts36g00.avioccdat
                             ,lr_cts36g00.lcvcod
                             ,lr_cts10g06.atdfnlflg)

    returning l_saldo
             ,l_condicao
  end if
 call ctc30g00_dados_loca(2, lr_cts36g00.lcvcod)
    returning lr_ret.resultado
             ,lr_ret.mensagem
             ,l_adcsgrtaxvlr

 if lr_ret.resultado <> 1 then
    error lr_ret.mensagem
    return
 end if


 call ctc18g00_dados_loja(1, lr_cts36g00.lcvcod ,lr_cts36g00.aviestcod)
    returning  lr_ret.resultado
              ,lr_ret.mensagem
              ,lr_ctc18g00.lcvextcod
              ,lr_ctc18g00.aviestnom
              ,lr_ctc18g00.lcvregprccod

 if lr_ret.resultado <> 1 then
    error lr_ret.mensagem
    return
 end if

 initialize lr_retorno.* to null
 call cts20g02(lr_param.atdsrvnum, lr_param.atdsrvano, "CAN")
      returning lr_retorno.*

 while true
    call cts36g01_prorrog(1,lr_param.atdsrvnum,lr_param.atdsrvano,l_cont)
       returning am_cts36g01[l_cont].resultado
                ,am_cts36g01[l_cont].mensagem
                ,am_cts36g01[l_cont].vclretdat
                ,am_cts36g01[l_cont].vclrethor
                ,am_cts36g01[l_cont].aviprodiaqtd
                ,am_cts36g01[l_cont].aviprosoldat
                ,am_cts36g01[l_cont].aviprosolhor
                ,am_cts36g01[l_cont].aviprostt

    if am_cts36g01[l_cont].resultado <> 1 then
       exit while
    end if

    let l_cont = l_cont + 1

    if l_cont > 50 then
       error 'Numero de registros excedeu o limite'
       let l_cont = l_cont - 1
       exit while
    end if
 end while

 if lr_param.enviar = 'F' or
    lr_param.enviar = 'I' or
    lr_param.enviar = 'E' then

    let m_arquivo = l_path  clipped, '/DAT',
                    lr_param.atdsrvnum using "<<<<<<<<<<", '.arq'

    if lr_param.enviar = 'I' or lr_param.enviar = "F"  then
       start report cts15m14_impressao
    else

# Inicio Altera��o - Fabrica BRQ - Luiz Gustavo - PSI-2012-26565/EV

       whenever error continue
       open ccts15m14005 using  lr_cts36g00.lcvcod

       fetch ccts15m14005 into  m_acntip

       whenever error stop

       if m_acntip = 1 then
        	 call cts15m14_temp_resp(lr_param.atdsrvnum, lr_param.atdsrvano) returning l_result
       end if

# Fim Altera��o - Fabrica BRQ - Luiz Gustavo - PSI-2012-26565/EV

       start report cts15m14_impressao to m_arquivo
    
    end if

    call cts15m14_PDF(lr_param.enviar
                     ,lr_param.destino
                     ,lr_param.dddcod
                     ,lr_param.facnum
                     ,lr_cts10g06.atddat
                     ,lr_cts10g06.atdhor
                     ,lr_cts10g06.atdsrvorg
                     ,lr_param.atdsrvnum
                     ,lr_param.atdsrvano
                     ,lr_cts10g06.nom
                     ,lr_cts36g00.avilocnom
                     ,lr_cts36g00.locrspcpfnum
                     ,lr_cts36g00.locrspcpfdig
                     ,lr_cts20g03.c24soltipcod
                     ,lr_cts20g03.c24solnom
                     ,lr_cts36g00.avivclvlr
                     ,lr_cts36g00.locsegvlr
                     ,lr_ctc17g00.avivclgrp
                     ,lr_ctc17g00.avivcldes
                     ,l_condicao
                     ,l_saldo
                     ,lr_ctc18g00.lcvextcod
                     ,lr_ctc18g00.aviestnom
                     ,lr_cts36g00.aviretdat
                     ,lr_cts36g00.avirethor
                     ,lr_cts36g00.aviprvent
                     ,lr_param.msg1
                     ,lr_param.msg2
                     ,lr_cts36g00.avirsrgrttip
                     ,lr_cts36g00.cdtoutflg
                     ,l_adcsgrtaxvlr
                     ,lr_cts36g00.lcvcod
                     ,lr_ctc18g00.lcvregprccod
                     ,l_descricao_veiculo
                     ,l_c24soltipdes
                     ,lr_param.execucao
                     ,m_ciaempcod
                     ,l_result
                     ,lr_param.faxch1
                     ,lr_param.faxch2)
  
    if lr_param.enviar = "E" or  lr_param.enviar = "I" then 
    
       if lr_param.enviar = "E" then
          let wsgpipe = null
       end if
       
       output to report cts15m14_impressao(lr_param.enviar
                                          ,lr_param.destino
                                          ,lr_param.dddcod
                                          ,lr_param.facnum
                                          ,lr_cts10g06.atddat
                                          ,lr_cts10g06.atdhor
                                          ,lr_cts10g06.atdsrvorg
                                          ,lr_param.atdsrvnum
                                          ,lr_param.atdsrvano
                                          ,lr_cts10g06.nom
                                          ,lr_cts36g00.avilocnom
                                          ,lr_cts36g00.locrspcpfnum
                                          ,lr_cts36g00.locrspcpfdig
                                          ,lr_cts20g03.c24soltipcod
                                          ,lr_cts20g03.c24solnom
                                          ,lr_cts36g00.avivclvlr
                                          ,lr_cts36g00.locsegvlr
                                          ,lr_ctc17g00.avivclgrp
                                          ,lr_ctc17g00.avivcldes
                                          ,l_condicao
                                          ,l_saldo
                                          ,lr_ctc18g00.lcvextcod
                                          ,lr_ctc18g00.aviestnom
                                          ,lr_cts36g00.aviretdat
                                          ,lr_cts36g00.avirethor
                                          ,lr_cts36g00.aviprvent
                                          ,lr_param.msg1
                                          ,lr_param.msg2
                                          ,lr_cts36g00.avirsrgrttip
                                          ,lr_cts36g00.cdtoutflg
                                          ,l_adcsgrtaxvlr
                                          ,lr_cts36g00.lcvcod
                                          ,lr_ctc18g00.lcvregprccod
                                          ,l_descricao_veiculo
                                          ,l_c24soltipdes
                                          ,lr_param.execucao
                                          ,m_ciaempcod  # Inicio Altera��o - Fabrica BRQ - Luiz Gustavo - PSI-2012-26565/EV
                                          ,l_result       )# Fim Altera��o - Fabrica BRQ - Luiz Gustavo - PSI-2012-26565/EV

       finish report cts15m14_impressao
    
    end if
    
 else
  output to report cts15m14_impressao(lr_param.enviar
                                     ,lr_param.destino
                                     ,lr_param.dddcod
                                     ,lr_param.facnum
                                     ,lr_cts10g06.atddat
                                     ,lr_cts10g06.atdhor
                                     ,lr_cts10g06.atdsrvorg
                                     ,lr_param.atdsrvnum
                                     ,lr_param.atdsrvano
                                     ,lr_cts10g06.nom
                                     ,lr_cts36g00.avilocnom
                                     ,lr_cts36g00.locrspcpfnum
                                     ,lr_cts36g00.locrspcpfdig
                                     ,lr_cts20g03.c24soltipcod
                                     ,lr_cts20g03.c24solnom
                                     ,lr_cts36g00.avivclvlr
                                     ,lr_cts36g00.locsegvlr
                                     ,lr_ctc17g00.avivclgrp
                                     ,lr_ctc17g00.avivcldes
                                     ,l_condicao
                                     ,l_saldo
                                     ,lr_ctc18g00.lcvextcod
                                     ,lr_ctc18g00.aviestnom
                                     ,lr_cts36g00.aviretdat
                                     ,lr_cts36g00.avirethor
                                     ,lr_cts36g00.aviprvent
                                     ,lr_param.msg1
                                     ,lr_param.msg2
                                     ,lr_cts36g00.avirsrgrttip
                                     ,lr_cts36g00.cdtoutflg
                                     ,l_adcsgrtaxvlr
                                     ,lr_cts36g00.lcvcod
                                     ,lr_ctc18g00.lcvregprccod
                                     ,l_descricao_veiculo
                                     ,l_c24soltipdes
                                     ,lr_param.execucao
                                     ,m_ciaempcod  # Inicio Altera��o - Fabrica BRQ - Luiz Gustavo - PSI-2012-26565/EV
                                     ,l_result       )# Fim Altera��o - Fabrica BRQ - Luiz Gustavo - PSI-2012-26565/EV


    finish report cts15m14_impressao
    call cts15m14_internet(lr_cts10g06.atddat
                          ,lr_cts10g06.atdhor
                          ,lr_cts10g06.atdsrvorg
                          ,lr_param.atdsrvnum
                          ,lr_param.atdsrvano
                          ,lr_cts10g06.nom
                          ,lr_cts36g00.avilocnom
                          ,lr_cts36g00.locrspcpfnum
                          ,lr_cts36g00.locrspcpfdig
                          ,lr_cts20g03.c24soltipcod
                          ,lr_cts20g03.c24solnom
                          ,lr_cts36g00.avivclvlr
                          ,lr_cts36g00.locsegvlr
                          ,lr_ctc17g00.avivclgrp
                          ,lr_ctc17g00.avivcldes
                          ,l_condicao
                          ,l_saldo
                          ,lr_ctc18g00.lcvextcod
                          ,lr_ctc18g00.aviestnom
                          ,lr_cts36g00.aviretdat
                          ,lr_cts36g00.avirethor
                          ,lr_cts36g00.aviprvent
                          ,lr_param.msg1
                          ,lr_param.msg2
                          ,lr_cts36g00.avirsrgrttip
                          ,lr_cts36g00.cdtoutflg
                          ,l_adcsgrtaxvlr
                          ,lr_cts36g00.lcvcod
                          ,lr_ctc18g00.lcvregprccod
                          ,l_descricao_veiculo
                          ,l_c24soltipdes
                          ,lr_param.acao
                          ,m_ciaempcod)

 end if
 
 
 

end function

#-----------------------------------------
function cts15m14_saldo_condicao(lr_param)
#-----------------------------------------

 define lr_param record
                 atdsrvnum like datmservico.atdsrvnum
                ,atdsrvano like datmservico.atdsrvano
                ,clscod    char(003)
                ,avivclgrp like datkavisveic.avivclgrp
                ,avialgmtv like datmavisrent.avialgmtv
                ,avioccdat like datmavisrent.avioccdat
                ,lcvcod    like datmavisrent.lcvcod
                ,atdfnlflg like datmservico.atdfnlflg
             end record

 define lr_ctx01g01 record
                    clscod like abbmclaus.clscod
                   ,viginc like abbmclaus.viginc
                   ,vigfnl like abbmclaus.vigfnl
                end record

 define lr_cts28g00 record
                    tem_apol  smallint
                   ,mensagem  char(080)
                   ,succod    like datrservapol.succod
                   ,aplnumdig like datrservapol.aplnumdig
                   ,itmnumdig like datrservapol.itmnumdig
                   ,edsnumref like datrservapol.edsnumref
                end record

 define lr_funapol record
                   resultado    char (1)
                  ,dctnumseq    like abbmdoc.dctnumseq
                  ,vclsitatu    like abbmitem.vclsitatu
                  ,autsitatu    like abbmitem.autsitatu
                  ,dmtsitatu    like abbmitem.dmtsitatu
                  ,dpssitatu    like abbmitem.dpssitatu
                  ,appsitatu    like abbmitem.appsitatu
                  ,vidsitatu    like abbmitem.vidsitatu
                  ,edstip       like abbmdoc.edstip
                  ,edsnumdig    like abamdoc.edsnumdig
               end record


 define l_saldo     char(100)
       ,l_condicao  char(100)
       ,l_coderro   smallint
       ,l_concedear smallint
       ,l_avidiaqtd smallint
       ,l_limite    smallint
       ,l_temcls    smallint
       ,l_lignum    like datmligacao.lignum

  initialize lr_ctx01g01 to null
  initialize lr_cts28g00 to null
  initialize lr_funapol  to null

  let l_saldo     = null
  let l_condicao  = null
  let l_coderro   = null
  let l_concedear = null
  let l_limite = null
  let l_avidiaqtd = null
  let l_temcls    = null
  let l_lignum    = null


 call cts28g00_apol_serv(2, lr_param.atdsrvnum, lr_param.atdsrvano)
    returning lr_cts28g00.tem_apol
             ,lr_cts28g00.mensagem
             ,lr_cts28g00.succod
             ,lr_cts28g00.aplnumdig
             ,lr_cts28g00.itmnumdig
             ,lr_cts28g00.edsnumref

  if m_cts15m14_prep is null or
     m_cts15m14_prep = false then
     call cts15m14_prepare()
  end if


  if g_documento.atdsrvnum is not null and
     g_documento.atdsrvano is not null then

    let l_lignum  = cts20g00_servico( g_documento.atdsrvnum,
                                      g_documento.atdsrvano )


    open ccts15m14001 using l_lignum
    whenever error continue
    fetch ccts15m14001 into g_documento.c24astcod
    whenever error stop

    if sqlca.sqlcode <> 0 then
       error "Erro ao localizar assunto original, Avise a informatica !"
    end if
 end if


 if lr_cts28g00.tem_apol = 1 and
    m_ciaempcod         <> 35 then
    call f_funapol_ultima_situacao_nova(lr_cts28g00.succod
                                       ,lr_cts28g00.aplnumdig
                                       ,lr_cts28g00.itmnumdig)
       returning lr_funapol.resultado
                ,lr_funapol.dctnumseq
                ,lr_funapol.vclsitatu
                ,lr_funapol.autsitatu
                ,lr_funapol.dmtsitatu
                ,lr_funapol.dpssitatu
                ,lr_funapol.appsitatu
                ,lr_funapol.vidsitatu


   # --> CONFORME SOLICITACAO DA ROSANA CT24HS, INIBIR A
   # VERIFICACAO DE VIGENCIA P/CONCESSAO DO AR CONDICIONADO
   # DATA SOLICITACAO: 22/03/2006
   # ---> VERIFICA SE A APOLICE POSSUI O BENEFICIO DO AR CONDICIONADO
   #call cts15m13_ver_ar_cond(lr_cts28g00.succod
   #                         ,lr_cts28g00.aplnumdig
   #                         ,lr_funapol.autsitatu
   #                         ,lr_cts28g00.itmnumdig
   #                         ,lr_cts28g00.edsnumref)
   #   returning l_coderro
   #            ,l_concedear
 end if

 # --> CONFORME SOLICITACAO DA ROSANA CT24HS, LIBERAR
 # VEICULOS COM AR CONDICIONADO PARA TODOS OS MOTIVOS DE
 # RESERVA : 09/05/2006.
 let l_concedear = true

 if lr_param.avivclgrp = "A"   or
   (lr_param.avivclgrp = "B" and l_concedear = true) then

    if lr_param.avialgmtv = 1 then

       if lr_cts28g00.tem_apol = 2 then
          if m_ciaempcod = 35 then
             case lr_param.clscod
             when '58A'
                let l_condicao = 'CLAUSULA 58A FATURAR DIARIAS P/ AZUL '
                                ,'SEGUROS ATE O LIMITE 05 DIARIAS '
             when '58B'
                let l_condicao = 'CLAUSULA 58B - FATURAR DIARIAS P/ AZUL '
                                ,'SEGUROS ATE O LIMITE 10 DIARIAS '
             when '58C'
                let l_condicao = 'CLAUSULA 58C - FATURAR DIARIAS P/ AZUL '
                                ,'SEGUROS ATE O LIMITE 15 DIARIAS '
             when '58D'
                let l_condicao = 'CLAUSULA 58D - FATURAR DIARIAS P/ AZUL '
                                ,'SEGUROS ATE O LIMITE 30 DIARIAS '
             when '58E'
                let l_condicao = 'CLAUSULA 58E FATURAR DIARIAS P/ AZUL '
                                ,'SEGUROS ATE O LIMITE 05 DIARIAS '
             when '58F'
                let l_condicao = 'CLAUSULA 58F - FATURAR DIARIAS P/ AZUL '
                                ,'SEGUROS ATE O LIMITE 10 DIARIAS '
             when '58G'
                let l_condicao = 'CLAUSULA 58G - FATURAR DIARIAS P/ AZUL '
                                ,'SEGUROS ATE O LIMITE 15 DIARIAS '
             when '58H'
                let l_condicao = 'CLAUSULA 58H - FATURAR DIARIAS P/ AZUL '
                                ,'SEGUROS ATE O LIMITE 30 DIARIAS '
             when '58I'
                let l_condicao = 'CLAUSULA 58I - FATURAR DIARIAS P/ AZUL '
                                ,'SEGUROS ATE O LIMITE 07 DIARIAS '
             when '58J'
                let l_condicao = 'CLAUSULA 58J - FATURAR DIARIAS P/ AZUL '
                                ,'SEGUROS ATE O LIMITE 15 DIARIAS '
             when '58K'
                let l_condicao = 'CLAUSULA 58K - FATURAR DIARIAS P/ AZUL '
                                ,'SEGUROS ATE O LIMITE 30 DIARIAS '
             when '58L'
                let l_condicao = 'CLAUSULA 58L - FATURAR DIARIAS P/ AZUL '
                                ,'SEGUROS ATE O LIMITE 07 DIARIAS '
             when '58M'
                let l_condicao = 'CLAUSULA 58M - FATURAR DIARIAS P/ AZUL '
                                ,'SEGUROS ATE O LIMITE 15 DIARIAS '
             when '58N'
                let l_condicao = 'CLAUSULA 58N - FATURAR DIARIAS P/ AZUL '
                                ,'SEGUROS ATE O LIMITE 30 DIARIAS '
             end case
          else
             case lr_param.clscod
             when '26A'
                let l_condicao = 'CLAUSULA 26A FATURAR DIARIAS P/ PORTO '
                                ,'SEGURO ATE O LIMITE 15 DIARIAS '
             when '26B'
                let l_condicao = 'CLAUSULA 26B - FATURAR DIARIAS P/ PORTO '
                                ,'SEGURO ATE O LIMITE 30 DIARIAS '
             when '26C'
                let l_condicao = 'CLAUSULA 26C - FATURAR DIARIAS P/ PORTO '
                                ,'SEGURO ATE O LIMITE 07 DIARIAS '
             when '26D'
                let l_condicao = 'CLAUSULA 26D - FATURAR DIARIAS P/ PORTO '
                                ,'SEGURO ATE O LIMITE 07 DIARIAS '
             ## psi201154
             when '26E'
                let l_condicao = 'CLAUSULA 26E FATURAR DIARIAS P/ PORTO '
                                ,'SEGURO ATE O LIMITE 07 DIARIAS '
             when '26F'
                let l_condicao = 'CLAUSULA 26F - FATURAR DIARIAS P/ PORTO '
                                ,'SEGURO ATE O LIMITE 30 DIARIAS '
             when '26G'
                let l_condicao = 'CLAUSULA 26G - FATURAR DIARIAS P/ PORTO '
                                ,'SEGURO ATE O LIMITE 07 DIARIAS '
             ## psi201154
             ## Carro Extra medio porte
             when '26H'
                let l_condicao = 'CLAUSULA 26H FATURAR DIARIAS P/ PORTO '
                                ,'SEGURO ATE O LIMITE 15 DIARIAS '
             when '26I'
                let l_condicao = 'CLAUSULA 26I - FATURAR DIARIAS P/ PORTO '
                                ,'SEGURO ATE O LIMITE 30 DIARIAS '
             when '26J'
                let l_condicao = 'CLAUSULA 26J - FATURAR DIARIAS P/ PORTO '
                                ,'SEGURO ATE O LIMITE 07 DIARIAS '
             when '26K'
                let l_condicao = 'CLAUSULA 26K - FATURAR DIARIAS P/ PORTO '
                                ,'SEGURO ATE O LIMITE 07 DIARIAS '
             when '26L'
                let l_condicao = 'CLAUSULA 26L FATURAR DIARIAS P/ PORTO '
                                ,'SEGURO ATE O LIMITE 15 DIARIAS '
             when '26M'
                let l_condicao = 'CLAUSULA 26M - FATURAR DIARIAS P/ PORTO '
                                ,'SEGURO ATE O LIMITE 30 DIARIAS '
             end case
          end if
       else
          if m_ciaempcod = 35 then
             call cts44g01_claus_azul(lr_cts28g00.succod,
                                      531               ,
                                      lr_cts28g00.aplnumdig,
                                      lr_cts28g00.itmnumdig)
                     returning l_temcls,lr_ctx01g01.clscod
          else
             call ctx01g01_claus_novo(lr_cts28g00.succod
                                     ,lr_cts28g00.aplnumdig
                                     ,lr_cts28g00.itmnumdig
                                     ,lr_param.avioccdat
                                     ,1
                                     ,lr_param.avialgmtv)
                 returning lr_ctx01g01.clscod
                          ,lr_ctx01g01.viginc
                          ,lr_ctx01g01.vigfnl
          end if
          if lr_ctx01g01.clscod[1,2] = 26 or
             lr_ctx01g01.clscod[1,2] = 44 or
             lr_ctx01g01.clscod[1,2] = 48 or
             lr_ctx01g01.clscod[1,2] = 80 or
             lr_ctx01g01.clscod[1,2] = 58 then

             if lr_param.atdfnlflg = 'N' then
                call ctx01g00_saldo_novo(lr_cts28g00.succod
                                               ,lr_cts28g00.aplnumdig
                                               ,lr_cts28g00.itmnumdig
                                               ,''
                                               ,''
                                               ,lr_param.avioccdat
                                               ,1,true
                                               ,m_ciaempcod
                                               ,lr_param.avialgmtv
                                               ,g_documento.c24astcod)
                     returning l_limite, l_avidiaqtd
             else
                call ctx01g00_saldo_novo(lr_cts28g00.succod
                                                ,lr_cts28g00.aplnumdig
                                                ,lr_cts28g00.itmnumdig
                                                ,lr_param.atdsrvnum
                                                ,lr_param.atdsrvano
                                                ,lr_param.avioccdat
                                                ,1,true
                                                ,m_ciaempcod
                                               ,lr_param.avialgmtv
                                               ,g_documento.c24astcod)
                     returning l_limite, l_avidiaqtd

             end if

             if l_avidiaqtd > 0  then
                let l_saldo = l_avidiaqtd using '&&', 'DIARIA(S) GRATUITA(S) '

                if m_ciaempcod = 35 then
                   let l_condicao = 'CLAUSULA ', lr_ctx01g01.clscod, ' - FATURAR DIARIAS P/ '
                                ,'AZUL SEGUROS ATE O  LIMITE DO SALDO '
                else
                   let l_condicao = 'CLAUSULA ', lr_ctx01g01.clscod, ' - FATURAR DIARIAS P/ '
                                ,'PORTO SEGURO ATE O  LIMITE DO SALDO '
                end if
             end if
          end if
       end if
    end if

    case lr_param.avialgmtv
       when 2
           let l_saldo = "7 DIARIAS"
           let l_condicao = "PANE MECANICA - FATURAR DIARIA(S) PARA PORTO SEGURO ATE O LIMITE DO SALDO"
       when 3
          if m_ciaempcod = 35 then
             let l_saldo    = '8 DIARIAS GRATUITAS '
             let l_condicao = 'BENEFICIO - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE DO SALDO '
          else
             #Psi 251429
             if g_documento.c24astcod = "H12" then
                let l_saldo = "15 DIARIAS"
                let l_condicao = 'FATURAR DIARIA(S) PARA PORTO SEGURO ATE O LIMITE DO SALDO'
             else
             	let l_saldo    = '7 DIARIAS GRATUITAS '
             	let l_condicao = 'BENEF.OFICINA - FATURAR DIARIAS P/ PORTO SEGURO ATE O LIMITE DO SALDO '
             end if
          end if
       when 4
          if m_ciaempcod = 35 then
             let l_condicao = 'DEPARTAMENTO: FATURAR DIARIAS PARA AZUL SEGUROS '
                             ,'(PREVISAO E PRORROGACOES   AUTORIZADAS PELA CIA)'
          else
             let l_condicao = 'DEPARTAMENTO: FATURAR DIARIAS PARA PORTO SEGURO '
                             ,'(PREVISAO E PRORROGACOES   AUTORIZADAS PELA CIA)'
          end if

       when 5
          # Conforme Judite Esteves foi retirado essa regra para locadora
          #if lr_param.lcvcod = 2 then
          #   let l_condicao = 'FATURAR DIARIAS INTEGRALMENTE PARA USUARIO '
          #else
             let l_condicao = 'PARTICULAR - FATURAR DIARIAS INTEGRALMENTE PARA USUARIO'
          #end if
       when 6
          #Psi 251429
          if g_documento.c24astcod = "H13" then
             let l_saldo = "15 DIARIAS"
             let l_condicao = 'FATURAR DIARIA(S) PARA PORTO SEGURO ATE O LIMITE DO SALDO'
          else
             let l_saldo    = '7 DIARIAS GRATUITAS '
             let l_condicao = 'TERC.SEGPORTO -  FATURAR DIARIAS P/ PORTO SEGURO '
                              ,'ATE O LIMITE DO SALDO '
          end if
       when 7
          let l_saldo    = '7 DIARIAS GRATUITAS '
          let l_condicao = 'TERC.QUALQUER -  FATURAR DIARIAS P/ PORTO SEGURO '
                          ,'ATE O LIMITE DO SALDO '
       when 8
          let l_saldo    = '7 DIARIAS GRATUITAS '
          let l_condicao = 'FATURAR DIARIAS P/ PORTO SEGURO ATE O LIMITE DO SALDO, '
                          ,'DEMAIS PARA USUARIO '
       when 9
          # Conforme Judite Esteves foi retirado essa regra para locadora
          #if lr_param.lcvcod = 2 then
          #   let l_condicao = 'FATURAR DIARIAS INTEGRALMENTE PARA USUARIO'
          #else ## Alberto DVP 39934
             let l_condicao = 'DIARIAS FATURADAS P/PORTO SEGURO ATE LIMITE DE(07 DIAS)DE SALDO DA CLAUSULA'
          #end if
       when 0
             let l_condicao = 'FATURAR PARA A PORTO SEGURO AS DIARIAS INFORMADAS EXCLUSIVAMENTE NO CAMPO PREV.USO'
       when 11
            let l_condicao = 'TOTAL DE DIARIAS FATURADAS PARA A AZUL SEGUROS'
       when 12
            let l_condicao = 'TOTAL DE DIARIAS FATURADAS PARA A AZUL SEGUROS'

       when 13
            let l_condicao = 'FATURAR ATE 30 DIAS PARA A PORTO SEGURO'

       when 14
            let l_condicao = 'TOTAL DE DIARIAS FATURADAS PARA A PORTO SEGURO'

       when 18
          if m_ciaempcod = 35 then
             let l_saldo    = '7 DIARIAS GRATUITAS '
             let l_condicao = 'BENEFICIO - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE DO SALDO '
          end if
          
       when 20
             let l_condicao = 'DIARIAS FATURADAS P/PORTO SEGURO ATE LIMITE DE (02 DIARIAS) DE SALDO DA CLAUSULA'
             
       when 21
             let l_condicao = 'DIARIAS FATURADAS P/PORTO SEGURO ATE LIMITE DE (15 DIARIAS) DE SALDO DA CLAUSULA'
             
       when 23
             let l_condicao = 'DIARIAS FATURADAS P/PORTO SEGURO ATE LIMITE DE (15 DIARIAS) DE SALDO DA CLAUSULA'
             
       when 24
             let l_condicao = 'DIARIAS FATURADAS P/PORTO SEGURO ATE LIMITE DE (15 DIARIAS) DE SALDO DA CLAUSULA'


    end case
 else
    case lr_param.avialgmtv
       when 1
       if lr_cts28g00.tem_apol = 2 then
             ## Carro Extra medio porte
             case lr_param.clscod
                 when '26H'
                    let l_condicao = 'CLAUSULA 26H FATURAR DIARIAS P/ PORTO '
                                    ,'SEGURO ATE O LIMITE 15 DIARIAS '
                 when '26I'
                    let l_condicao = 'CLAUSULA 26I - FATURAR DIARIAS P/ PORTO '
                                    ,'SEGURO ATE O LIMITE 30 DIARIAS '
                 when '26J'
                    let l_condicao = 'CLAUSULA 26J - FATURAR DIARIAS P/ PORTO '
                                    ,'SEGURO ATE O LIMITE 07 DIARIAS '
                 when '26K'
                    let l_condicao = 'CLAUSULA 26K - FATURAR DIARIAS P/ PORTO '
                                    ,'SEGURO ATE O LIMITE 07 DIARIAS '
                 when '26L'
                    let l_condicao = 'CLAUSULA 26L FATURAR DIARIAS P/ PORTO '
                                    ,'SEGURO ATE O LIMITE 15 DIARIAS '
                 when '26M'
                    let l_condicao = 'CLAUSULA 26M - FATURAR DIARIAS P/ PORTO '
                                    ,'SEGURO ATE O LIMITE 30 DIARIAS '
             end case
       else
             call ctx01g01_claus_novo(lr_cts28g00.succod
                                     ,lr_cts28g00.aplnumdig
                                     ,lr_cts28g00.itmnumdig
                                     ,lr_param.avioccdat
                                     ,1
                                     ,lr_param.avialgmtv)
                 returning lr_ctx01g01.clscod
                          ,lr_ctx01g01.viginc
                          ,lr_ctx01g01.vigfnl
               if lr_ctx01g01.clscod[1,2] = 26 or
                  lr_ctx01g01.clscod[1,2] = 44 or
                  lr_ctx01g01.clscod[1,2] = 48 or
                  lr_ctx01g01.clscod[1,2] = 80 or
                  lr_ctx01g01.clscod[1,2] = 58 then
                  if lr_param.atdfnlflg = 'N' then
                     call ctx01g00_saldo_novo(lr_cts28g00.succod
                                                    ,lr_cts28g00.aplnumdig
                                                    ,lr_cts28g00.itmnumdig
                                                    ,''
                                                    ,''
                                                    ,lr_param.avioccdat
                                                    ,1,true
                                                    ,m_ciaempcod
                                               ,lr_param.avialgmtv
                                               ,g_documento.c24astcod)
                          returning l_limite, l_avidiaqtd
                  else
                     call ctx01g00_saldo_novo(lr_cts28g00.succod
                                                     ,lr_cts28g00.aplnumdig
                                                     ,lr_cts28g00.itmnumdig
                                                     ,lr_param.atdsrvnum
                                                     ,lr_param.atdsrvano
                                                     ,lr_param.avioccdat
                                                     ,1,true
                                                     ,m_ciaempcod
                                               ,lr_param.avialgmtv
                                               ,g_documento.c24astcod)
                          returning l_limite, l_avidiaqtd
                  end if
                  if l_avidiaqtd > 0  then
                     let l_saldo = l_avidiaqtd using '&&', ' DIARIA(S) GRATUITA(S) '
                        let l_condicao = 'CLAUSULA ', lr_ctx01g01.clscod, ' - FATURAR DIARIAS P/ '
                                     ,'PORTO SEGURO ATE O  LIMITE DO SALDO '
                  end if
               end if
       end if
       when 2
           let l_saldo = '7 DIARIAS'
           let l_condicao = "PANE MECANICA - FATURAR DIARIA(S) PARA PORTO SEGURO ATE O LIMITE DO SALDO"
       when 4
          if m_ciaempcod = 35 then
             let l_condicao = 'DEPARTAMENTO: FATURAR DIARIAS PARA AZUL SEGUROS '
                             ,'(PREVISAO E PRORROGACOES AUTORIZADAS PELA CIA)'
          else
             let l_condicao = 'DEPARTAMENTO: FATURAR DIARIAS PARA PORTO SEGURO '
                             ,'(PREVISAO E PRORROGACOES AUTORIZADAS PELA CIA)'
          end if

       when 5
          # Conforme Judite Esteves foi retirado essa regra para locadora
          #if lr_param.lcvcod = 2 then
          #   let l_condicao = 'FATURAR DIARIAS INTEGRALMENTE PARA USUARIO '
          #else
             let l_condicao = 'PARTICULAR - FATURAR DIARIAS INTEGRALMENTE PARA USUARIO '
          #end if

       when 6
          let l_saldo    = '7 DIARIAS'
          let l_condicao = 'TERC.SEGPORTO -  FATURAR DIARIAS P/PORTO SEGURO ATE O LIMITE DO SALDO '
       when 7
          let l_saldo    = '7 DIARIAS'
          let l_condicao = 'TERC.QUALQUER -  FATURAR DIARIAS P/ PORTO SEGURO '
                          ,'ATE O LIMITE DO SALDO '
       when 8
          let l_condicao = 'FATURAR DIARIAS P/PORTO SEGURO ATE O LIMITE DO SALDO E DEMAIS PARA USUARIO '
       when 9
          # Conforme Judite Esteves foi retirado essa regra para locadora
          #if lr_param.lcvcod = 2  then
          #  let l_condicao = 'FATURAR DIARIAS INTEGRALMENTE PARA USUARIO '
          #else
             let l_saldo = '7 DIARIAS'
             let l_condicao = 'FATURAR DIARIAS P/PORTO SEGURO ATE O LIMITE DO SALDO E DEMAIS PARA USUARIO '
          #end if
       when 0
              let l_condicao = 'FATURAR PARA A PORTO SEGURO AS DIARIAS',
                               ' INFORMADAS EXCLUSIVAMENTE NO CAMPO PREV.USO'
       when 11
            let l_condicao = 'TOTAL DE DIARIAS FATURADAS PARA A AZUL SEGUROS'
       when 12
            let l_condicao = 'TOTAL DE DIARIAS FATURADAS PARA A AZUL SEGUROS'

       when 13
            let l_condicao = 'FATURAR ATE 30 DIAS PARA A PORTO SEGURO'

       when 14
            let l_condicao = 'TOTAL DE DIARIAS FATURADAS PARA A PORTO SEGURO'

        when 18
          if m_ciaempcod = 35 then
             let l_saldo    = '7 DIARIAS GRATUITAS '
             let l_condicao = 'BENEFICIO - FATURAR DIARIAS P/ AZUL SEGUROS ATE O LIMITE DO SALDO '
          end if
          
        when 20
             let l_condicao = 'DIARIAS FATURADAS P/PORTO SEGURO ATE LIMITE DE (02 DIARIAS) DE SALDO DA CLAUSULA'
            
        when 21
              let l_condicao = 'DIARIAS FATURADAS P/PORTO SEGURO ATE LIMITE DE (15 DIARIAS) DE SALDO DA CLAUSULA'
              
        when 23
              let l_condicao = 'DIARIAS FATURADAS P/PORTO SEGURO ATE LIMITE DE (15 DIARIAS) DE SALDO DA CLAUSULA'
              
        when 24
              let l_condicao = 'DIARIAS FATURADAS P/PORTO SEGURO ATE LIMITE DE (15 DIARIAS) DE SALDO DA CLAUSULA'

    end case

 end if

 return l_saldo
       ,l_condicao

end function

#-----------------------------------------
function cts15m14_saldo_condicao_itau(lr_param)
#-----------------------------------------

 define lr_param record
                 atdsrvnum like datmservico.atdsrvnum
                ,atdsrvano like datmservico.atdsrvano
                ,clscod    char(003)
                ,avivclgrp like datkavisveic.avivclgrp
                ,avialgmtv like datmavisrent.avialgmtv
                ,avioccdat like datmavisrent.avioccdat
                ,lcvcod    like datmavisrent.lcvcod
                ,atdfnlflg like datmservico.atdfnlflg
             end record

 define l_saldo     char(100)
       ,l_condicao  char(100)
       ,l_coderro   smallint
       ,l_concedear smallint
       ,l_avidiaqtd smallint
       ,l_temcls    smallint
       ,l_lignum    like datmligacao.lignum
       ,l_diarias   smallint


  let l_saldo     = null
  let l_condicao  = null
  let l_coderro   = null
  let l_concedear = null
  let l_avidiaqtd = null
  let l_temcls    = null
  let l_lignum    = null
  let l_diarias   = 0

  if m_cts15m14_prep is null or
     m_cts15m14_prep = false then
     call cts15m14_prepare()
  end if


  if g_documento.atdsrvnum is not null and
     g_documento.atdsrvano is not null then

    let l_lignum  = cts20g00_servico( g_documento.atdsrvnum,
                                      g_documento.atdsrvano )


    open ccts15m14001 using l_lignum
    whenever error continue
    fetch ccts15m14001 into g_documento.c24astcod
    whenever error stop

    if sqlca.sqlcode <> 0 then
       error "Erro ao localizar assunto original, Avise a informatica !"
    end if
 end if


 whenever error continue
 open ccts15m14002 using lr_param.atdsrvnum,
                         lr_param.atdsrvano
 fetch ccts15m14002 into l_diarias
 whenever error stop


 if lr_param.avialgmtv = 6 or
 	  lr_param.avialgmtv = 8 then
     let l_condicao = "PARTICULAR - FATURAR DIARIAS INTEGRALMENTE PARA USUARIO"
 else
    let l_saldo = l_diarias using "&&&", " DIARIAS"
    let l_condicao = "FATURAR DIARIA(S) PARA ITAU SEGUROS DE AUTO E RESIDENCIA ATE O LIMITE DO SALDO"
 end if

 return l_saldo
       ,l_condicao

end function

#----------------------------------
report cts15m14_impressao(lr_param)
#----------------------------------

 define lr_param record
                 enviar        char(001)
                ,destino       char(024)
                ,dddcod        like datklocadora.dddcod
                ,facnum        like datklocadora.facnum
                ,atddat        like datmservico.atddat
                ,atdhor        like datmservico.atdhor
                ,atdsrvorg     like datmservico.atdsrvorg
                ,atdsrvnum     like datmservico.atdsrvnum
                ,atdsrvano     like datmservico.atdsrvano
                ,nom           like datmservico.nom
                ,avilocnom     like datmavisrent.avilocnom
                ,locrspcpfnum  like datmavisrent.locrspcpfnum
                ,locrspcpfdig  like datmavisrent.locrspcpfdig
                ,c24soltipcod  like datksoltip.c24soltipcod
                ,c24solnom     like datksoltip.c24soltipdes
                ,avivclvlr     like datmavisrent.avivclvlr
                ,locsegvlr     like datmavisrent.locsegvlr
                ,avivclgrp     like datkavisveic.avivclgrp
                ,avivcldes     like datkavisveic.avivcldes
                ,condicao      char(100)
                ,saldo         char(100)
                ,lcvextcod     like datkavislocal.lcvextcod
                ,aviestnom     like datkavislocal.aviestnom
                ,aviretdat     like datmavisrent.aviretdat
                ,avirethor     like datmavisrent.avirethor
                ,aviprvent     like datmavisrent.aviprvent
                ,msg1          char(050)
                ,msg2          char(050)
                ,avirsrgrttip  like datmavisrent.avirsrgrttip
                ,cdtoutflg     like datmavisrent.cdtoutflg
                ,adcsgrtaxvlr  like datklocadora.adcsgrtaxvlr
                ,lcvcod        like datmavisrent.lcvcod
                ,lcvregprccod  like datkavislocal.lcvregprccod
                ,descricao     char(100)
                ,c24soltipdes  like datksoltip.c24soltipdes
                ,execucao      char(80)
                ,ciaempcod     like datmservico.ciaempcod
# Inicio Altera��o - Fabrica BRQ - Luiz Gustavo - PSI-2012-26565/EV
                ,result        datetime hour to minute
# Fim Altera��o - Fabrica BRQ - Luiz Gustavo - PSI-2012-26565/EV
             end record

 define l_linha char(66)

 define l_i     smallint

 define l_emailtitulo char(040)

 define l_psaerrcod integer
 
    define lr_telefoneSegurado record
       smsenvdddnum       like datmrsvvcl.smsenvdddnum
      ,smsenvcelnum    like datmrsvvcl.smsenvcelnum
      ,cttdddcod        like datmavisrent.cttdddcod
      ,ctttelnum    like datmavisrent.ctttelnum
   end record

 output report to pipe wsgpipe
    page   length    66
    left   margin    00
    right  margin   130
    top    margin    00
    bottom margin    00

 format
    on every row

       initialize l_psaerrcod to null

       if lr_param.enviar = 'F' then
          case lr_param.ciaempcod
            when 1
             # -> IMPRIME O LOGO PARA A PORTO SEGURO
             print column 001, "@+IMAGE[porto.tif]"
             skip  7 lines

            when 50 ---> Saude
             # -> IMPRIME O LOGO PARA A PORTO SEGURO
             print column 001, "@+IMAGE[porto.tif]"
             skip  7 lines

            when 35
              # -> IMPRIME O LOGO PARA A AZUL SEGUROS
              print column 001, "@+IMAGE[azul.tif]"
              skip  6 lines

            when 43   #--> PSI-2013-06224/PR
               call cts59g00_idt_srv_saps(1, lr_param.atdsrvnum, lr_param.atdsrvano) returning l_psaerrcod

               if l_psaerrcod = 0  # servi�o SAPS
                  then
                  # compilacao do TIF para fax nao disponivel, sera disponibilizado projeto substitui��o do VSIfax
                  # print column 001, "@+IMAGE[saps.tif]"
                  print column 001, "@+IMAGE[porto.tif]"
                  skip 8 lines
               end if
          end case
       else
          if lr_param.enviar = 'I' then    ## Impressao
             print column 001, "Enviar para: ", lr_param.destino, "    Fax: ", "(", lr_param.dddcod , ")"
                             , lr_param.facnum using "<<<<<<<<&"  ## Anatel
             skip  2 lines
          end if
       end if

# Inicio Altera��o - Fabrica BRQ - Luiz Gustavo - PSI-2012-26565/EV

       if m_acntip = 1 then
          let l_emailtitulo = 'Reserva: ', lr_param.atdsrvnum using "##########",  '-'
                             ,lr_param.atdsrvano using '&&'

          if lr_retorno.c24astcod = "CAN" then
             let l_emailtitulo = l_emailtitulo clipped, " CANCELADO"
          end if

          print "MIME-Version: 1.0"
          print "Content-Type: multipart/mixed;"
          print ' boundary="BOUNDARY"'
          print "Subject: ", l_emailtitulo
          print ""
          print "This is a MIME-encapsulated message"
          print "--BOUNDARY"
          print "Content-Type: text/plain"
          print ""
          print ""
          print "--BOUNDARY"
          print "Content-Type: text/html"
          print "<html>"
          print "<body font-family:'sans-serif'>"
          print "<PRE>"
          print "<H3>"
       end if

# Fim Altera��o - Fabrica BRQ - Luiz Gustavo - PSI-2012-26565/EV

       if lr_param.ciaempcod = 35 then # -> AZUL SEGUROS
          print column 006, "RESERVA DE VEICULO - AZUL SEGUROS",
                column 050, "Data: ", lr_param.atddat,
                column 070, "Hora: ", lr_param.atdhor
          print column 006, "================================="
       else
          if lr_param.ciaempcod = 84 then # -> ITAU SEGUROS DE AUTO E RESIDENCIA
             print column 006, "RESERVA DE VEICULO-ITAU SEGUROS DE AUTO E RESIDENCIA",
                   column 050, "Data: ", lr_param.atddat,
                   column 070, "Hora: ", lr_param.atdhor
             print column 006, "================================="
          else
             if lr_param.ciaempcod = 43 and l_psaerrcod = 0   #--> PSI-2013-06224/PR
                then
                print column 006, "RESERVA DE VEICULO - SERVICOS AVULSOS PORTO SEGURO",
                      column 050, "Data: ", lr_param.atddat,
                      column 070, "Hora: ", lr_param.atdhor
                print column 006, "=================================================="
             else
                print column 006, "RESERVA DE VEICULO - PORTO SEGURO",
                      column 050, "Data: ", lr_param.atddat,
                      column 070, "Hora: ", lr_param.atdhor
                print column 006, "================================="
             end if
          end if
       end if

       skip  1 line

       if lr_retorno.c24astcod is null then
          print column 006, "No. SERVICO.: ", lr_param.atdsrvorg using "&&"    ,
                                      "/", lr_param.atdsrvnum using "&&&&&&&",
                                      "-", lr_param.atdsrvano using "&&"
       else
          print column 006, "No. SERVICO.: ", lr_param.atdsrvorg using "&&"    ,
                                      "/", lr_param.atdsrvnum using "&&&&&&&",
                                      "-", lr_param.atdsrvano using "&&",
                                      " CANCELADO "
       end if

       if lr_param.lcvcod = 2 then
          if lr_param.ciaempcod = 1  or
             lr_param.ciaempcod = 50 then ---> Saude
             print column 050, "NOSSO CODIGO: 634-546"
          end if

          if lr_param.ciaempcod = 35 then
             print column 050, "NOSSO CODIGO: 224-8945"
          end if
       else
          if lr_param.lcvcod = 4  then
             print column 050, "NOSSO CODIGO: B02885"
          else
             print " "
          end if
       end if

       skip  1 lines

       if lr_retorno.c24astcod is null then
          print column 006, "Autorizamos a locacao de veiculo conforme as seguintes condicoes:"
       else
          print column 006, "Cancelamos a locacao de veiculo conforme as seguintes condicoes:"
       end if
       
          whenever error continue                 
          open  ccts15m14006 using lr_param.atdsrvnum
                                  ,lr_param.atdsrvano
          fetch ccts15m14006 into  lr_telefoneSegurado.smsenvdddnum     
                                  ,lr_telefoneSegurado.smsenvcelnum  
                                  ,lr_telefoneSegurado.cttdddcod
                                  ,lr_telefoneSegurado.ctttelnum 
          whenever error stop
          close ccts15m14006 
          
       skip  1 lines
       print column 001, "______________________________ DADOS DO LOCATARIO ______________________________"
       skip  1 line
       print column 001, "Segurado.: ", lr_param.nom
       skip  1 line
       print column 001, "Usuario..: ", lr_param.avilocnom
       if lr_param.locrspcpfnum is not null then
          print column 048, "CPF....: ", lr_param.locrspcpfnum using "#########",
                                    "-", lr_param.locrspcpfdig using "##"
                                    
                                    
                                    
             if lr_telefoneSegurado.smsenvdddnum       is not null and lr_telefoneSegurado.smsenvdddnum      > 0 and
                lr_telefoneSegurado.smsenvcelnum    is not null and lr_telefoneSegurado.smsenvcelnum   > 0 and
                lr_telefoneSegurado.cttdddcod  is not null and lr_telefoneSegurado.cttdddcod > 0 and
                lr_telefoneSegurado.ctttelnum     is not null and lr_telefoneSegurado.ctttelnum    > 0 then
             
                  skip  1 line
                  print column 001, " Telefone....: "
                  , "(", lr_telefoneSegurado.smsenvdddnum using "##" clipped, ") "
                  , lr_telefoneSegurado.smsenvcelnum using "#########" clipped, " / "
                  , "(", lr_telefoneSegurado.cttdddcod using "##" clipped, ") "
                  , lr_telefoneSegurado.ctttelnum using "#########" clipped           
                  
             else
                 if lr_telefoneSegurado.smsenvdddnum is not null and lr_telefoneSegurado.smsenvdddnum> 0 and
                    lr_telefoneSegurado.smsenvcelnum is not null and lr_telefoneSegurado.smsenvcelnum> 0 then
                    
                       skip  1 line
                       print column 001, " Telefone....: "
                       , "(", lr_telefoneSegurado.smsenvdddnum using "##" clipped, ") "
                       , lr_telefoneSegurado.smsenvcelnum using "#########" clipped
                 else
                    if lr_telefoneSegurado.cttdddcod  is not null and lr_telefoneSegurado.cttdddcod > 0 and
                       lr_telefoneSegurado.ctttelnum     is not null and lr_telefoneSegurado.ctttelnum    > 0 then
                            
                           skip  1 line
                           print column 001, " Telefone....: "
                           , "(", lr_telefoneSegurado.cttdddcod using "##" , ") "
                           , lr_telefoneSegurado.ctttelnum  using "#########" clipped
                    end if
                 end if
             end if                                     
       else
          print ''
       end if

       skip  1 line
       print column 001, "Solicit..: ", lr_param.c24solnom,
             column 048, "Tipo...: "  , lr_param.c24soltipdes
       skip  1 line

       print column 001, "________________________ DADOS DO VEICULO PREFERENCIAL _________________________"
       skip  1 line

       let lr_param.avivclvlr = lr_param.avivclvlr + lr_param.locsegvlr

       print column 001, "Grupo....: ", lr_param.avivclgrp
       skip  1 line
       print column 001, "Veiculo..: ", lr_param.descricao
       skip  1 line

       let l_linha = lr_param.condicao[1,66]

       print column 001, "Condicao.: ", l_linha
       if length(lr_param.condicao)> 65 then
         skip  1 line
         let l_linha = lr_param.condicao[66,100]
         print column 012, l_linha
       end if

       if lr_param.saldo is not null then
          skip  1 line
          print column 001, "Saldo....: ", lr_param.saldo
       end if

       skip  1 line
       print column 001, "Loja.....: ", lr_param.lcvextcod,
                                 " - ", lr_param.aviestnom
       skip  1 line
       print column 001, "Retirada.: ", lr_param.aviretdat,
             column 028, "Hora..: "   , lr_param.avirethor,
             column 048, "Prev. Uso: ", lr_param.aviprvent using '&&', ' Dia(s)'
       skip  1 line

       if lr_param.msg1 is not null or
          lr_param.msg2 is not null then
          print column 001, "_________________________________ OBSERVACOES __________________________________"
          skip  1 line
          print column 001, lr_param.msg1
          print column 001, lr_param.msg2
          skip  1 line
       end if
       print column 001, "__________________________ CONSIDERACOES IMPORTANTES ___________________________"
       skip  1 line

       case lr_param.avirsrgrttip
          when 1
             print column 001, "- LOCACAO SERA FEITA ATRAVES DE CARTAO DE CREDITO"
          when 2
             print column 001, "- LOCACAO SERA FEITA ATRAVES DE CHEQUE CAUCAO"
          when 3
             print column 001, "- LOCACAO ISENTA DE APRESENTACAO DO CARTAO DE CREDITO OU CHEQUE COM GARANTIA"
             if lr_param.ciaempcod = 35 then
                print column 001, "  (CAUCAO) SOB TOTAL RESPONSABILIDADE DA AZUL SEGUROS"
             else
                if lr_param.ciaempcod = 43 and l_psaerrcod = 0   #--> PSI-2013-06224/PR
                   then
                   print column 001, "  (CAUCAO) SOB TOTAL RESPONSABILIDADE DA SERVICOS AVULSOS PORTO SEGURO"
                else
                   print column 001, "  (CAUCAO) SOB TOTAL RESPONSABILIDADE DA PORTO SEGURO"
                end if
             end if
       end case

       if lr_param.cdtoutflg is not null and
          lr_param.cdtoutflg =  "S"      then
          print column 001, "- PARA ESTA LOCACAO HAVERA SEGUNDO(S) CONDUTOR(ES)"
       end if

       print column 001, "- COMBUSTIVEL, HORAS E TAXAS EXTRAS (PROTECAO OPCIONAL) POR CONTA DO USUARIO."

       print column 001, "________________________________ CONTATOS ___________________________"
       skip  1 line

# Inicio Altera��o - Fabrica BRQ - Luiz Gustavo - PSI-2012-26565/EV

       if m_acntip = 1 and m_atdetpcod = 1 then
       	 print column 001, "- APOS O RECEBIMENTO DESTE, A LOCADORA PODERA RESPONDER A CONFIRMACAO DESTA"
          print column 001, " RESERVA ATE AS ", lr_param.result, ", APOS ESTE HORARIO SOLICITACAO DE"
          print column 001, " RESERVA SERA CANCELADA."

          print "<P>"

          if g_outFigrc012.Is_Teste then
             print column 001, "<P>- POR FAVOR RESPONDER DISPONIBILIDADE DA RESERVA: "
                             , "<a HREF='http://aplwebtst/pspsr/reserva/ReservaPortoSeguro.aspx?macsissgl=PSRONLINE&portal=2&"
                             , "NumeroServico=", lr_param.atdsrvnum using '<<<<<<<<<<'
                             , "&AnoServico=", lr_param.atdsrvano using '<<'
                             , "&CodigoLocadora=", lr_param.lcvcod using '<<<<<<<<<<'
                             , "'>CLICAR AQUI</a> PARA "
          else
             print column 001, "<P>- POR FAVOR RESPONDER DISPONIBILIDADE DA RESERVA: "
                             , "<a HREF='https://wwws.portoseguro.com.br/pspsr/reserva/ReservaPortoSeguro.aspx?macsissgl=PSRONLINE&portal=2&"
                             , "NumeroServico=", lr_param.atdsrvnum using '<<<<<<<<<<'
                             , "&AnoServico=", lr_param.atdsrvano using '<<'
                             , "&CodigoLocadora=", lr_param.lcvcod using '<<<<<<<<<<'
                             , "'>CLICAR AQUI</a> PARA "

          end if

          print column 001, "RESPONDER DISPONIBILIDADE."
       else
          print column 001, "- APOS O RECEBIMENTO DESTE, A LOCADORA DISPOE DE 0:20MIN. PARA NEGAR A RESERVA"
          print column 001, "  POR FALTA DE VEICULOS."
       end if

# Fim Altera��o - Fabrica BRQ - Luiz Gustavo - PSI-2012-26565/EV

       if lr_param.ciaempcod = 35 then # -> AZUL SEGUROS
          print column 001, "- TELEFONE PARA RETORNO: (011) 3366-3629 "
       else
          if lr_param.ciaempcod = 43 and l_psaerrcod = 0  #--> PSI-2013-06224/PR
             then
             print column 001, "- TELEFONE PARA RETORNO: (011) 3366-3055 "
          else
             print column 001, "- TELEFONE PARA RETORNO: (011) 3366-3629 - PORTO SEGURO"
          end if
       end if

       if lr_param.adcsgrtaxvlr is not null and
          lr_param.adcsgrtaxvlr <> 0        then
          if lr_param.lcvcod = 2        and
             lr_param.lcvregprccod = 2  then

             ###INIBIDO CONFORME SOLICITACAO DA SILMARA - 18/08/06 - Lucas Scheid
             ###print column 001, "- A LOJA NAO OPERA COM TAXA DE ISENCAO DE FRANQUIA"

             print column 001, "- A LOJA NAO OPERA COM TAXA DE ISENCAO NA PARTICIPACAO EM CASO DE SINISTRO"

          else

             ###INIBIDO CONFORME SOLICITACAO DA SILMARA - 18/08/06 - Lucas Scheid
             ###print column 001, "- A LOCADORA OFERECERA TAXA DE ISENCAO DE FRANQUIA (COBERTURA DE RISCO),"
             ###print column 001, "  OPTATIVA, AO CUSTO DE R$ ",
             ###                   lr_param.adcsgrtaxvlr using  "<<<,<<&.&&", "/DIA."

             print column 001, "- A LOCADORA OFERECERA TAXA DE ISENCAO NA PARTICIPACAO EM CASO DE SINISTRO"
             print column 001, "  (COBERTURA DE RISCO), OPTATIVA, AO CUSTO DE R$ ",
                                lr_param.adcsgrtaxvlr using  "<<<,<<&.&&", "/DIA."

          end if
       end if

       skip  1 line
       print column 001, "_________________________________ PRORROGACOES _________________________________"
       skip  1 line

       for l_i = 1 to 50
          if am_cts36g01[l_i].aviprosoldat is null then
             let l_i = l_i - 1
             exit for
          end if

          print column 001, "==> EM ", am_cts36g01[l_i].aviprosoldat,
                               " AS ", am_cts36g01[l_i].aviprosolhor
          if am_cts36g01[l_i].aviprostt = "C"  then
             print "   *** CANCELADA! ***"
          else
             print " "
          end if
          skip  1 line
          print column 001, "    DATA DE PRORROGACAO: ", am_cts36g01[l_i].vclretdat
          print column 001, "    HORA DE PRORROGACAO: ", am_cts36g01[l_i].vclrethor
          print column 001, "    PREVISAO DE USO....: ", am_cts36g01[l_i].aviprodiaqtd using "<<<<<<", " DIA(S)"
          skip  1 line

       end for


       if am_cts36g01[1].aviprosoldat is null then
          print column 001, "NENHUMA."
       end if

       if lr_param.enviar = 'I' then
          print ascii(12)
       end if

# Inicio Altera��o - Fabrica BRQ - Luiz Gustavo - PSI-2012-26565/EV

       if m_acntip = 1 then
          print "</H3>"
          print "</PRE>"
          print "</body>"
          print "</html>"
          print "--BOUNDARY"
       end if

# Fim Altera��o - Fabrica BRQ - Luiz Gustavo - PSI-2012-26565/EV

end report

#-----------------------------------
function cts15m14_internet(lr_param)
#-----------------------------------

 define lr_param record
                 atddat        like datmservico.atddat
                ,atdhor        like datmservico.atdhor
                ,atdsrvorg     like datmservico.atdsrvorg
                ,atdsrvnum     like datmservico.atdsrvnum
                ,atdsrvano     like datmservico.atdsrvano
                ,nom           like datmservico.nom
                ,avilocnom     like datmavisrent.avilocnom
                ,locrspcpfnum  like datmavisrent.locrspcpfnum
                ,locrspcpfdig  like datmavisrent.locrspcpfdig
                ,c24soltipcod  like datksoltip.c24soltipcod
                ,c24solnom     like datksoltip.c24soltipdes
                ,avivclvlr     like datmavisrent.avivclvlr
                ,locsegvlr     like datmavisrent.locsegvlr
                ,avivclgrp     like datkavisveic.avivclgrp
                ,avivcldes     like datkavisveic.avivcldes
                ,condicao      char(100)
                ,saldo         char(100)
                ,lcvextcod     like datkavislocal.lcvextcod
                ,aviestnom     like datkavislocal.aviestnom
                ,aviretdat     like datmavisrent.aviretdat
                ,avirethor     like datmavisrent.avirethor
                ,aviprvent     like datmavisrent.aviprvent
                ,msg1          char(050)
                ,msg2          char(050)
                ,avirsrgrttip  like datmavisrent.avirsrgrttip
                ,cdtoutflg     like datmavisrent.cdtoutflg
                ,adcsgrtaxvlr  like datklocadora.adcsgrtaxvlr
                ,lcvcod        like datmavisrent.lcvcod
                ,lcvregprccod  like datkavislocal.lcvregprccod
                ,descricao     char(100)
                ,c24soltipdes  like datksoltip.c24soltipdes
                ,acao          char(1)
                ,ciaempcod     like datmservico.ciaempcod
             end record

 define l_i smallint

 define l_psaerrcod smallint

 initialize l_psaerrcod to null

 call cts59g00_idt_srv_saps(1, lr_param.atdsrvnum, lr_param.atdsrvano) returning l_psaerrcod

 if lr_param.acao <> 2 then

    if lr_retorno.c24astcod is null then
       display "PADRAO@@1@@B@@C@@0@@Autorizamos a loca��o do ve�culo conforme as seguintes condi��es@@"
    else
       display "PADRAO@@1@@B@@C@@0@@Cancelamos a loca��o do ve�culo conforme as seguintes condi��es@@"
    end if

    if lr_param.ciaempcod = 1  or   #Porto
       lr_param.ciaempcod = 50 then #Saude
       display "PADRAO@@1@@B@@C@@0@@Laudo do servi�o@@"
    else if lr_param.ciaempcod = 35 then #Azul
            display "PADRAO@@1@@B@@C@@0@@Laudo do servi�o - AZUL SEGUROS@@"
         else
            if lr_param.ciaempcod = 43 and l_psaerrcod = 0   #--> PSI-2013-06224/PR
               then
               display "PADRAO@@1@@B@@C@@0@@Laudo de Servi�os Avulsos Porto Seguro@@"
            end if
         end if
    end if

    if lr_retorno.c24astcod is null then
       display "PADRAO@@8@@N�mero do  servi�o@@", lr_param.atdsrvnum using "<<<<<<<<<<","/", lr_param.atdsrvano using "&&", "@@"
    else
       display "PADRAO@@8@@N�mero do  servi�o@@", lr_param.atdsrvnum using "<<<<<<<<<<","/", lr_param.atdsrvano using "&&", "  CANCELADO@@"
    end if

    display "PADRAO@@1@@B@@C@@0@@Dados do Locat�rio@@"

    display "PADRAO@@8@@Segurado@@", lr_param.nom, "@@"

    display "PADRAO@@8@@Usu�rio@@", lr_param.avilocnom, "@@"

    display "PADRAO@@8@@CPF@@", lr_param.locrspcpfnum,"/", lr_param.locrspcpfdig, "@@"
    display "PADRAO@@8@@Solicitante@@", lr_param.c24solnom, "@@"

    display "PADRAO@@8@@Tipo do solicitante@@", lr_param.c24soltipdes, "@@"

    display "PADRAO@@1@@B@@C@@0@@Dados do ve�culo preferencial@@"

    display "PADRAO@@8@@Grupo@@", lr_param.avivclgrp,'-', lr_param.avivcldes, "@@"
    display "PADRAO@@8@@Ve�culo@@", lr_param.descricao, "@@"

    display "PADRAO@@8@@Condi��o@@", lr_param.condicao, "@@"

    display "PADRAO@@8@@Loja@@", lr_param.lcvextcod, " - ", lr_param.aviestnom, "@@"
    display "PADRAO@@8@@Data da retirada@@", lr_param.aviretdat, "@@"

    display "PADRAO@@8@@Hora da retirada@@", lr_param.avirethor, "@@"

    display "PADRAO@@8@@Previs�o de uso@@", lr_param.aviprvent using '&&', ' Dia(s)', "@@"

    display "PADRAO@@1@@B@@C@@0@@Considera��es importantes@@"

    display "PADRAO@@1@@N@@L@@1@@- COMBUST�VEL, HORAS E TAXAS EXTRAS (PROTE��O OPCIONAL) POR CONTA DO USU�RIO.@@"

    display "PADRAO@@1@@N@@L@@1@@- AP�S O RECEBIMENTO DESTE, A LOCADORA DISP�E DE 0:20 MIN. PARA NEGAR A RESERVA POR FALTA DE VE�CULOS.@@"

    if lr_param.ciaempcod = 35 then  # Azul Seguros
       display "PADRAO@@1@@N@@L@@1@@- TELEFONE PARA RETORNO: (011) 3366-3629@@"
    else
       if lr_param.ciaempcod = 43 and l_psaerrcod = 0  #--> PSI-2013-06224/PR
          then
          display "PADRAO@@1@@N@@L@@1@@- TELEFONE PARA RETORNO: (011) 3366-3055@@"
       else
          display "PADRAO@@1@@N@@L@@1@@- TELEFONE PARA RETORNO: (011) 3366-3629 - PORTO SEGURO@@"
       end if
    end if

    case lr_param.avirsrgrttip
       when 1
         display "PADRAO@@1@@N@@L@@1@@- LOCA��O SER� FEITA ATRAV�S DE CART�O DE CR�DITO@@"
       when 2
         display "PADRAO@@1@@N@@L@@1@@- LOCA��O SER� FEITA ATRAV�S DE CHEQUE CAU��O@@"
    end case

    if lr_param.cdtoutflg is not null  and
       lr_param.cdtoutflg = "S" then
       display "PADRAO@@1@@N@@L@@1@@- PARA ESTA LOCA��O HAVER� SEGUNDO(S) CONDUTOR(ES)@@"
    end if

    if lr_param.adcsgrtaxvlr is not null and
       lr_param.adcsgrtaxvlr <> 0    then

       if lr_param.lcvcod = 2  and lr_param.lcvregprccod = 2  then

          ### INIBIDO CONFORME SOLICITACAO DA SILMARA - 18/08/06 - Lucas Scheid
          ### display "PADRAO@@1@@N@@L@@1@@- A LOJA N�O OPERA COM TAXA DE ISEN��O DE FRANQUIA@@"

          display "PADRAO@@1@@N@@L@@1@@- A LOJA N�O OPERA COM TAXA DE ISEN��O NA PARTICIPA��O EM CASO DE SINISTRO@@"

       else
          ### INIBIDO CONFORME SOLICITACAO DA SILMARA - 18/08/06 - Lucas Scheid
          ###display "PADRAO@@1@@N@@L@@1@@- A LOCADORA OFERECER� TAXA DE ISEN��O DE FRANQUIA (COBERTURA DE RISCO),@@"
          ###display "PADRAO@@1@@N@@L@@1@@  OPTATIVA, AO CUSTO DE R$ ",  lr_param.adcsgrtaxvlr using "<<<,<<&.&&", "/DIA.@@"

          display "PADRAO@@1@@N@@L@@1@@- A LOCADORA OFERECER� TAXA DE ISEN��O NA PARTICIPA��O EM CASO DE SINISTRO@@"
          display "PADRAO@@1@@N@@L@@1@@  (COBERTURA DE RISCO), OPTATIVA, AO CUSTO DE R$ ",  lr_param.adcsgrtaxvlr using "<<<,<<&.&&", "/DIA.@@"

       end if
    end if

    display "PADRAO@@1@@B@@C@@0@@Prorroga��es@@"

    for l_i = 1 to 50
        if am_cts36g01[l_i].aviprosoldat is null then
           let l_i = l_i - 1
           exit for
        end if

       display "PADRAO@@1@@N@@L@@1@@==> EM ", am_cts36g01[l_i].aviprosoldat,"@@"
       display "PADRAO@@1@@N@@L@@1@@    AS ", am_cts36g01[l_i].aviprosolhor,"@@"

        if am_cts36g01[l_i].aviprostt = "C"  then
           display "PADRAO@@1@@N@@L@@1@@   *** CANCELADA! *** @@"
        end if

        display "PADRAO@@1@@N@@L@@1@@DATA DE PRORROGA��O: ", am_cts36g01[l_i].vclretdat, "@@"
        display "PADRAO@@1@@N@@L@@1@@HORA DE PRORROGA��O: ", am_cts36g01[l_i].vclrethor, "@@"
        display "PADRAO@@1@@N@@L@@1@@PREVIS�O DE USO....: ", am_cts36g01[l_i].aviprodiaqtd using "<<<<<<", " DIA(S)", "@@"

    end for

    if am_cts36g01[1].aviprosoldat is null then
       display "PADRAO@@1@@N@@L@@1@@NENHUMA.@@"
    end if

    if lr_param.acao = 1 then
       display "BOTAO@@Aceitar@@wdatc024.pl@@"
    end if

 else

    if lr_retorno.c24astcod is null then
       display "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Autorizamos a loca��o do ve�culo conforme as seguintes condi��es@@@@"
    else
       display "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Cancelamos a loca��o do ve�culo conforme as seguintes condi��es@@@@"
    end if

    if lr_param.ciaempcod = 1  or   #Porto
       lr_param.ciaempcod = 50 then #Saude
       display "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Laudo do servi�o@@@@"
    else if lr_param.ciaempcod = 35 then #Azul
            display "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Laudo do servi�o - AZUL SEGUROS@@@@"
         else
            if lr_param.ciaempcod = 43 and l_psaerrcod = 0   #--> PSI-2013-06224/PR
               then
               display "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Laudo de Servi�os Avulsos Porto Seguro@@@@"
            end if
         end if
    end if

    if lr_retorno.c24astcod is null then
       display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@N�mero do  servi�o@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_param.atdsrvnum using "<<<<<<<<<<","/", lr_param.atdsrvano using "&&", "@@@@"
    else
       display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@N�mero do  servi�o@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_param.atdsrvnum using "<<<<<<<<<<","/", lr_param.atdsrvano using "&&", "  CANCELADO@@"
    end if

    display "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Dados do Locat�rio@@@@"
    display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Segurado@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_param.nom, "@@@@"

    display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Usu�rio@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_param.avilocnom, "@@@@"

    display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@CPF@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_param.locrspcpfnum,"/", lr_param.locrspcpfdig, "@@@@"

    display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Solicitante@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_param.c24solnom, "@@@@"

    display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Tipo do solicitante@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_param.c24soltipdes, "@@@@"

    display "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Dados do ve�culo preferencial@@@@"

    display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Grupo@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_param.avivclgrp,'-', lr_param.avivcldes, "@@@@"

    display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Ve�culo@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_param.descricao, "@@@@"

    display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Condi��o@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_param.condicao, "@@@@"

    display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Loja@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_param.lcvextcod, " - ", lr_param.aviestnom, "@@@@"

    display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Data da retirada@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_param.aviretdat, "@@@@"

    display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Hora da retirada@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_param.avirethor, "@@@@"

    display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@025%@@Previs�o de uso@@@@N@@L@@M@@4@@3@@1@@075%@@", lr_param.aviprvent using '&&', ' Dia(s)', "@@@@"

    display "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Considera��es importantes@@@@"

    display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@0%@@@@@@N@@L@@M@@4@@3@@1@@100%@@- COMBUST�VEL, HORAS E TAXAS EXTRAS (PROTE��O OPCIONAL) POR CONTA DO USU�RIO.@@@@"

    display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@0%@@@@@@N@@L@@M@@4@@3@@1@@100%@@- AP�S O RECEBIMENTO DESTE, A LOCADORA DISP�E DE 0:20 MIN. PARA NEGAR A RESERVA POR FALTA DE VE�CULOS.@@@@"

    if lr_param.ciaempcod = 35 then
       display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@0%@@@@@@N@@L@@M@@4@@3@@1@@100%@@- TELEFONE PARA RETORNO: (011) 3366-3629@@@@"
    else
       if lr_param.ciaempcod = 43 and l_psaerrcod = 0  #--> PSI-2013-06224/PR
          then
          display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@0%@@@@@@N@@L@@M@@4@@3@@1@@100%@@- TELEFONE PARA RETORNO: (011) 3366-3055@@@@"
       else
          display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@0%@@@@@@N@@L@@M@@4@@3@@1@@100%@@- TELEFONE PARA RETORNO: (011) 3366-3629 - PORTO SEGURO@@@@"
       end if
    end if

    case lr_param.avirsrgrttip
       when 1
         display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@0%@@@@@@N@@L@@M@@4@@3@@1@@100%@@- LOCA��O SER� FEITA ATRAV�S DE CART�O DE CR�DITO@@@@"
       when 2
         display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@0%@@@@@@N@@L@@M@@4@@3@@1@@100%@@- LOCA��O SER� FEITA ATRAV�S DE CHEQUE CAU��O@@@@"
    end case

    if lr_param.cdtoutflg is not null  and
       lr_param.cdtoutflg = "S" then
       display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@0%@@@@@@N@@L@@M@@4@@3@@1@@100%@@- PARA ESTA LOCA��O HAVER� SEGUNDO(S) CONDUTOR(ES)@@@@"
    end if

    if lr_param.adcsgrtaxvlr is not null and
       lr_param.adcsgrtaxvlr <> 0    then

       if lr_param.lcvcod = 2  and lr_param.lcvregprccod = 2  then

          ### INIBIDO CONFORME SOLICITACAO DA SILMARA - 18/08/06 - Lucas Scheid
          ### display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@0%@@@@@@N@@L@@M@@4@@3@@1@@100%@@- A LOJA N�O OPERA COM TAXA DE ISEN��O DE FRANQUIA@@@@"

          display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@0%@@@@@@N@@L@@M@@4@@3@@1@@100%@@- A LOJA N�O OPERA COM TAXA DE ISEN��O NA PARTICIPA��O EM CASO DE SINISTRO@@@@"

       else
          ### INIBIDO CONFORME SOLICITACAO DA SILMARA - 18/08/06 - Lucas Scheid
          ### display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@0%@@@@@@N@@L@@M@@4@@3@@1@@100%@@- A LOCADORA OFERECER� TAXA DE ISEN��O DE FRANQUIA (COBERTURA DE RISCO),@@@@"
          ### display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@0%@@@@@@N@@L@@M@@4@@3@@1@@100%@@  OPTATIVA, AO CUSTO DE R$ ",  lr_param.adcsgrtaxvlr using "<<<,<<&.&&", "/DIA.@@@@"

          display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@0%@@@@@@N@@L@@M@@4@@3@@1@@100%@@- A LOCADORA OFERECER� TAXA DE ISEN��O NA PARTICIPA��O EM CASO DE SINISTRO@@@@"
          display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@0%@@@@@@N@@L@@M@@4@@3@@1@@100%@@  (COBERTURA DE RISCO), OPTATIVA, AO CUSTO DE R$ ",  lr_param.adcsgrtaxvlr using "<<<,<<&.&&", "/DIA.@@@@"

       end if
    end if

    display "PADRAO@@10@@1@@2@@1@@B@@C@@M@@4@@3@@2@@100%@@Prorroga��es@@@@"

    for l_i = 1 to 50
        if am_cts36g01[l_i].aviprosoldat is null then
           let l_i = l_i - 1
           exit for
        end if

       display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@0%@@@@@@N@@L@@M@@4@@3@@1@@100%@@==> EM ", am_cts36g01[l_i].aviprosoldat,"@@@@"

       display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@0%@@@@@@N@@L@@M@@4@@3@@1@@100%@@    AS ", am_cts36g01[l_i].aviprosolhor,"@@@@"

        if am_cts36g01[l_i].aviprostt = "C"  then
           display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@0%@@@@@@N@@L@@M@@4@@3@@1@@100%@@   *** CANCELADA! *** @@@@"
        end if

        display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@0%@@@@@@N@@L@@M@@4@@3@@1@@100%@@DATA DE PRORROGA��O: ", am_cts36g01[l_i].vclretdat, "@@@@"

        display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@0%@@@@@@N@@L@@M@@4@@3@@1@@100%@@HORA DE PRORROGA��O: ", am_cts36g01[l_i].vclrethor, "@@@@"

        display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@0%@@@@@@N@@L@@M@@4@@3@@1@@100%@@PREVIS�O DE USO....: ", am_cts36g01[l_i].aviprodiaqtd using "<<<<<<", " DIA(S)", "@@@@"

    end for

    if am_cts36g01[1].aviprosoldat is null then
       display "PADRAO@@10@@2@@2@@0@@N@@L@@M@@4@@3@@1@@0%@@@@@@N@@L@@M@@4@@3@@1@@100%@@NENHUMA.@@@@"
    end if

 end if

end function

#--------------------------------
function cts15m14_email(lr_param)
#--------------------------------

 define lr_param record
       atdsrvnum like datmservico.atdsrvnum
      ,atdsrvano like datmservico.atdsrvano
      ,maides    char(080)
      ,enviar    char(001)
      ,msg1      char(60)
      ,msg2      char(60)
 end record

 define l_comando     char(250)
       ,l_erro        smallint

 define lr_email record
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

 let  l_comando = null
 let  l_erro    = null
 initialize lr_retorno.*, lr_email.*, lr_anexo.* to null

 if lr_param.enviar = 'T' then
    call cts15m14_carro_extra(lr_param.atdsrvnum
                             ,lr_param.atdsrvano
                             ,''
                             ,''
                             ,''
                             ,''
                             ,''
                             ,'E'
                             ,lr_param.msg1
                             ,lr_param.msg2
                             ,''
                             ,'',0)
 end if

 if lr_param.maides is not null and lr_param.maides <> " " then
    let lr_email.ass = 'Reserva: ', lr_param.atdsrvnum using "##########",  '-'
                                   , lr_param.atdsrvano using '&&'

    if lr_retorno.c24astcod = "CAN" then
       let lr_email.ass = lr_email.ass clipped, " CANCELADO"
    end if
    
     let lr_email.rem = 'central.24horas@porto-seguro.com.br'
     let lr_email.des = lr_param.maides
     let lr_email.ccp = null
     let lr_email.cco = null
     let lr_email.msg = m_texto clipped
     let lr_email.tip = 'html'

     let lr_anexo.anexo1 = m_arquivo

# Inicio Altera��o - Fabrica BRQ - Luiz Gustavo - PSI-2012-26565/EV
   if m_acntip = 1 then
       let l_erro = ctx22g00_envia_email_overload(lr_email.*, lr_anexo.anexo1)
       if  l_erro <> 0 then
           if  l_erro <> 99 then
               display "Erro ao enviar email(ctx22g00)"
           else
               display "Erro no destinatario de email cts15m14"
           end if
       end if
   else
       let l_erro = ctx22g00_envia_email_anexos(lr_email.*, lr_anexo.*)
       if  l_erro <> 0 then
           if  l_erro <> 99 then
               display "Erro ao enviar email(ctx22g00)"
           else
               display "Erro no destinatario de email cts15m14"
           end if
       end if
   end if

# Fim Altera��o - Fabrica BRQ - Luiz Gustavo - PSI-2012-26565/EV

    let l_comando = 'rm ', m_arquivo
    run l_comando

 end if


end function

# Inicio Altera��o - Fabrica BRQ - Luiz Gustavo - PSI-2012-26565/EV

#-----------------------------------------------------#
function cts15m14_temp_resp(lr_atdsrvnum, lr_atdsrvano)
#-----------------------------------------------------#
   define l_result datetime hour to minute

   define lr_atdsrvnum like datmservico.atdsrvnum
         ,lr_atdsrvano like datmservico.atdsrvano
         ,l_grlinf     like datkgeral.grlinf
         ,lr_atdetpdat  like datmsrvacp.atdetpdat
         ,lr_atdetphor  like datmsrvacp.atdetphor
         ,lr_atdsrvseq  like datmsrvacp.atdsrvseq
         ,l_aux int

   initialize lr_atdetpdat to null
   initialize lr_atdetphor to null
   initialize lr_atdsrvseq to null
   initialize lr_atdsrvseq to null
   initialize l_result     to null
   let m_atdetpcod = 0


   whenever error continue
     open ccts15m14003 using  lr_atdsrvnum
                             ,lr_atdsrvano

     fetch ccts15m14003 into  lr_atdetpdat
                             ,lr_atdetphor
                             ,lr_atdsrvseq
                             ,m_atdetpcod
   whenever error stop
     close ccts15m14003

   whenever error continue
     open ccts15m14004

     fetch ccts15m14004 into l_grlinf
   whenever error stop
     close ccts15m14004

   let l_aux = l_grlinf

   let l_result = lr_atdetphor + l_aux units minute

   return l_result

end function

# Fim Altera��o - Fabrica BRQ - Luiz Gustavo - PSI-2012-26565/EV


#-----------------------------------------------------#
function cts15m14_PDF(lr_param)
#-----------------------------------------------------#

   define l_xml            char(32765)
   define l_arquivo        char(32765)
   define l_docHandle      integer
   define l_fileName       char(300)
         ,l_data           date
         ,l_logoemp        char(15)
         ,l_pulalinha_2    char(10)
         ,l_dadosreserva   char(2000)
         ,l_dadoslocatario char(2000)
         ,l_dadosveiculo   char(2000)
         ,l_observacoes    char(2000)
         ,l_consideracoes  char(2000)
         ,l_contatos       char(2000)
         ,l_prorrogacoes   char(12000)
         ,l_cia            char(200)
         ,l_nossocodigo    char(30)
         ,l_mensagem       char(100)
         ,l_linha          char(100)
         ,l_consi          char(100)
         ,l_i              smallint
         ,l_char           char(2000)
         ,l_cancelado      char(10)
         ,l_tip            smallint
         ,l_path_jasper    char(100)  # Rodolfo Massini - F0113761
         ,l_path_output    char(100)  # Rodolfo Massini - F0113761
         ,l_pulalinha_22   char(10)
         ,l_result         datetime hour to minute

   define lr_param record
          enviar        char(001)
         ,destino       char(024)
         ,dddcod        like datklocadora.dddcod
         ,facnum        like datklocadora.facnum
         ,atddat        like datmservico.atddat
         ,atdhor        like datmservico.atdhor
         ,atdsrvorg     like datmservico.atdsrvorg
         ,atdsrvnum     like datmservico.atdsrvnum
         ,atdsrvano     like datmservico.atdsrvano
         ,nom           like datmservico.nom
         ,avilocnom     like datmavisrent.avilocnom
         ,locrspcpfnum  like datmavisrent.locrspcpfnum
         ,locrspcpfdig  like datmavisrent.locrspcpfdig
         ,c24soltipcod  like datksoltip.c24soltipcod
         ,c24solnom     like datksoltip.c24soltipdes
         ,avivclvlr     like datmavisrent.avivclvlr
         ,locsegvlr     like datmavisrent.locsegvlr
         ,avivclgrp     like datkavisveic.avivclgrp
         ,avivcldes     like datkavisveic.avivcldes
         ,condicao      char(100)
         ,saldo         char(100)
         ,lcvextcod     like datkavislocal.lcvextcod
         ,aviestnom     like datkavislocal.aviestnom
         ,aviretdat     like datmavisrent.aviretdat
         ,avirethor     like datmavisrent.avirethor
         ,aviprvent     like datmavisrent.aviprvent
         ,msg1          char(050)
         ,msg2          char(050)
         ,avirsrgrttip  like datmavisrent.avirsrgrttip
         ,cdtoutflg     like datmavisrent.cdtoutflg
         ,adcsgrtaxvlr  like datklocadora.adcsgrtaxvlr
         ,lcvcod        like datmavisrent.lcvcod
         ,lcvregprccod  like datkavislocal.lcvregprccod
         ,descricao     char(100)
         ,c24soltipdes  like datksoltip.c24soltipdes
         ,execucao      char(80)
         ,ciaempcod     like datmservico.ciaempcod
         ,result        datetime hour to minute
         ,faxch1        like datmfax.faxch1
         ,faxch2        like datmfax.faxch2
   end record

   define lr_retornoFax record
       idFax     integer,
       codigoErro     smallint,
       status     smallint,
       mensagem char(1500),
       sucesso char(5)
   end record

   define lr_retornoConFax record
       idFax     integer,
       codigoErro     smallint,
       status     smallint,
       mensagem char(1500),
       sucesso char(5)
   end record
   
    define lr_telefoneSegurado record
       smsenvdddnum       like datmrsvvcl.smsenvdddnum
      ,smsenvcelnum    like datmrsvvcl.smsenvcelnum
      ,cttdddcod        like datmavisrent.cttdddcod
      ,ctttelnum    like datmavisrent.ctttelnum
   end record

   define lr_fax    record
       telefone     dec(10,0),
       destinatario char(30),
       notas        char(30),
       caminhoarq   char(100)
   end record
   
   # Rodolfo Massini - Inicio - F0113761
   whenever error continue
    
    # Obter parametro do PATH de OUTPUT
    select grlinf
      into l_path_output
      from datkgeral
     where grlchv = 'PSOFAXDIROUTPUT'

	if sqlca.sqlcode <> 0 then
       let l_path_output = '\\\\nt112\\DOCPDF\\PSOCOR\\output\\' clipped
    end if

	# Obter parametro do PATH do JASPER
    select grlinf
      into l_path_jasper
      from datkgeral
     where grlchv = 'PSOFAXDIRJASPER'

    if sqlca.sqlcode <> 0 then
	   let l_path_jasper = '\\\\nt112\\DOCPDF\\PSOCOR\\jasper\\' clipped
    end if

   whenever error stop
   # Rodolfo Massini - Fim - F0113761

   if lr_param.dddcod = '11'  or
      lr_param.dddcod = '011' or
      lr_param.dddcod = '1511'  then
      let lr_fax.telefone = lr_param.facnum using '<<&&&&&&&&' # Rodolfo Massini - F0113761
   else
      let l_char = lr_param.dddcod using '<<&&' # Rodolfo Massini - F0113761
                           ,lr_param.facnum using '<<&&&&&&&&' # Rodolfo Massini - F0113761
      let lr_fax.telefone = l_char clipped
   end if


   let lr_fax.destinatario = lr_param.lcvextcod

   let lr_fax.notas = ""

   display 'lr_fax.telefone: ', lr_fax.telefone


   let l_filename = lr_param.atdsrvnum
   let lr_fax.caminhoarq = l_path_output clipped,l_filename clipped, '.pdf'
   display 'lr_fax.caminhoarq: ', lr_fax.caminhoarq clipped
   let l_pulalinha_2 = '<br>'
   let l_pulalinha_22 = '<br>'
   let l_data = current
   case lr_param.ciaempcod
      when 1
         let l_logoemp = 'logo.jpg'
         let l_cia = "- PORTO SEGURO           Data: "
      when 35 ---> Saude
         let l_logoemp = 'azul.png'
         let l_cia = "- AZUL SEGUROS            Data: "
      when 84
         let l_logoemp = 'itau.png'
         let l_cia = "- ITAU AUTO E RESIDENCIA Data: "
   end case

   if lr_param.lcvcod = 2 then
      if lr_param.ciaempcod = 1  or
         lr_param.ciaempcod = 50 then ---> Saude
         let l_nossocodigo = "                                NOSSO CODIGO: 634-546"
      end if
      if lr_param.ciaempcod = 35 then
          let l_nossocodigo = "                                NOSSO CODIGO: 224-8945"
      end if
   else
      if lr_param.lcvcod = 4  then
         let l_nossocodigo = "                                NOSSO CODIGO: B02885"
      else
         let l_nossocodigo = " "
      end if
   end if
               
   whenever error continue                 
   open  ccts15m14006 using lr_param.atdsrvnum
                           ,lr_param.atdsrvano
   fetch ccts15m14006 into  lr_telefoneSegurado.smsenvdddnum     
                           ,lr_telefoneSegurado.smsenvcelnum  
                           ,lr_telefoneSegurado.cttdddcod
                           ,lr_telefoneSegurado.ctttelnum 
   whenever error stop
   close ccts15m14006                
   
   if lr_retorno.c24astcod is null then
      let l_mensagem = "Autorizamos a locacao de veiculo conforme as seguintes condicoes:"
   else
      let l_mensagem = "Cancelamos a locacao de veiculo conforme as seguintes condicoes:"
   end if
   if lr_retorno.c24astcod is null then
      let l_cancelado = " "
   else
      let l_cancelado = "CANCELADO"
   end if

   let l_dadosreserva = " RESERVA DE VEICULO ", l_cia clipped
                       ," ",lr_param.atddat
                       ,"    Hora: ", lr_param.atdhor, l_pulalinha_2
                       ,"=================================", l_pulalinha_2
                       , l_pulalinha_2
                       , l_pulalinha_2
                       ,"No. SERVICO.: "
                       ,lr_param.atdsrvorg using "&&", "/"
                       ,lr_param.atdsrvnum using "<<<<<<<", "-"
                       ,lr_param.atdsrvano using "&&", " "
                       ,l_cancelado clipped
                       ,l_nossocodigo, l_pulalinha_2
                       ,l_mensagem clipped
   let l_dadoslocatario = "______________________________ DADOS DO LOCATARIO ______________________________"
                       ,l_pulalinha_2
                       ,l_pulalinha_2
                       ,"Segurado.: ", lr_param.nom clipped
                       ,l_pulalinha_2
                       ,"Usuario..: ", lr_param.avilocnom clipped
                       ,l_pulalinha_2

   if lr_param.locrspcpfnum is not null then
      let l_dadoslocatario = l_dadoslocatario clipped
             , "                                              CPF.........: "
             , lr_param.locrspcpfnum using "#########"
             ,"-", lr_param.locrspcpfdig using "##", l_pulalinha_2

             if lr_telefoneSegurado.smsenvdddnum       is not null and lr_telefoneSegurado.smsenvdddnum      > 0 and
                lr_telefoneSegurado.smsenvcelnum    is not null and lr_telefoneSegurado.smsenvcelnum   > 0 and
                lr_telefoneSegurado.cttdddcod  is not null and lr_telefoneSegurado.cttdddcod > 0 and
                lr_telefoneSegurado.ctttelnum     is not null and lr_telefoneSegurado.ctttelnum    > 0 then

                  let l_dadoslocatario = l_dadoslocatario clipped
                  , " Telefone....: "
                  , "(", lr_telefoneSegurado.smsenvdddnum using "##" clipped, ") "
                  , lr_telefoneSegurado.smsenvcelnum using "#########" clipped, " / "
                  , "(", lr_telefoneSegurado.cttdddcod using "##" clipped, ") "
                  , lr_telefoneSegurado.ctttelnum using "#########" clipped, l_pulalinha_2

             else
                 if lr_telefoneSegurado.smsenvdddnum is not null and lr_telefoneSegurado.smsenvdddnum> 0 and
                    lr_telefoneSegurado.smsenvcelnum is not null and lr_telefoneSegurado.smsenvcelnum> 0 then

                       let l_dadoslocatario = l_dadoslocatario clipped
                       , " Telefone....: "
                       , "(", lr_telefoneSegurado.smsenvdddnum using "##" clipped, ") "
                       , lr_telefoneSegurado.smsenvcelnum using "#########" clipped, l_pulalinha_2
                 else
                    if lr_telefoneSegurado.cttdddcod  is not null and lr_telefoneSegurado.cttdddcod > 0 and
                       lr_telefoneSegurado.ctttelnum     is not null and lr_telefoneSegurado.ctttelnum    > 0 then

                           let l_dadoslocatario = l_dadoslocatario clipped
                           , " Telefone....: "
                           , "(", lr_telefoneSegurado.cttdddcod using "##" , ") "
                           , lr_telefoneSegurado.ctttelnum  using "#########" clipped, l_pulalinha_2
                    end if
                 end if
             end if

             let l_dadoslocatario = l_dadoslocatario clipped

   else
      let l_dadoslocatario = l_dadoslocatario clipped, l_pulalinha_2
   end if

   let l_dadoslocatario = l_dadoslocatario clipped
                       ," Solicit..: ", lr_param.c24solnom clipped
                       ,l_pulalinha_2
                       ,"Tipo.....: "
                       , lr_param.c24soltipdes clipped, l_pulalinha_2
   let l_dadosveiculo = "________________________ DADOS DO VEICULO PREFERENCIAL _________________________"
                      , l_pulalinha_2
                      , l_pulalinha_2
                      , "Grupo....: ", lr_param.avivclgrp, l_pulalinha_2
                      , l_pulalinha_2
                      , "Veiculo..: ", lr_param.descricao, l_pulalinha_2
                      , l_pulalinha_2

   let l_linha = lr_param.condicao[1,66]

   let l_dadosveiculo = l_dadosveiculo clipped, " Condicao.: ", l_linha
   if length(lr_param.condicao)> 65 then
     let l_linha = l_pulalinha_2, lr_param.condicao[66,100]
     let l_dadosveiculo = l_dadosveiculo clipped,l_linha
   end if

   if lr_param.saldo is not null then
      let l_dadosveiculo = l_dadosveiculo clipped,
          l_pulalinha_2
          ,"Saldo....: ", lr_param.saldo, l_pulalinha_2
   end if

   let l_dadosveiculo = l_dadosveiculo clipped
                       ,l_pulalinha_2
                       ,"Loja.....: ", lr_param.lcvextcod clipped
                       ," - ", lr_param.aviestnom  clipped
                       , l_pulalinha_2
                       ,"Retirada.: ", lr_param.aviretdat
                       ,"       "
                       ,"Hora..: "   , lr_param.avirethor
                       ,"       "
                       ,"Prev. Uso: ", lr_param.aviprvent using '&&', ' Dia(s)'


   let l_observacoes = "_________________________________ OBSERVACOES __________________________________"
                     , l_pulalinha_2
                     , l_pulalinha_2
                     , lr_param.msg1 clipped ,l_pulalinha_2
                     , lr_param.msg2 clipped ,l_pulalinha_2

   let l_consideracoes = "__________________________ CONSIDERACOES IMPORTANTES ___________________________"
                        , l_pulalinha_2
                        , l_pulalinha_2

   case lr_param.avirsrgrttip
      when 1
         let l_consi = "- LOCACAO SERA FEITA ATRAVES DE CARTAO DE CREDITO"

      when 2
         let l_consi = "- LOCACAO SERA FEITA ATRAVES DE CHEQUE CAUCAO"
      when 3
         let l_consi = "- LOCACAO ISENTA DE APRESENTACAO DO CARTAO DE CREDITO OU CHEQUE COM GARANTIA"
         if lr_param.ciaempcod = 35 then
            let l_consi = "(CAUCAO) SOB TOTAL RESPONSABILIDADE DA AZUL SEGUROS"
         else
            if lr_param.ciaempcod = 01 then
               let l_consi = "(CAUCAO) SOB TOTAL RESPONSABILIDADE DA PORTO SEGURO"
            else
               let l_consi = "(CAUCAO) SOB TOTAL RESPONSABILIDADE DA ITAU SEGURRO AUTO E RESIDENCIA"
            end if
         end if
   end case

   let l_consideracoes = l_consideracoes clipped, " ",l_consi clipped, l_pulalinha_2

   if lr_param.cdtoutflg is not null and
      lr_param.cdtoutflg =  "S"      then
      let l_consideracoes = l_consideracoes clipped,
                         " - PARA ESTA LOCACAO HAVERA SEGUNDO(S) CONDUTOR(ES)"
                         ,l_pulalinha_2
   end if

   let l_consideracoes = l_consideracoes clipped,
                         " - COMBUSTIVEL, HORAS E TAXAS EXTRAS (PROTECAO OPCIONAL) POR CONTA DO USUARIO."
                         , l_pulalinha_2
   let l_contatos = "__________________________________ CONTATOS ____________________________________"
                  , l_pulalinha_2
                  , l_pulalinha_2
                  , "- APOS O RECEBIMENTO DESTE, A LOCADORA DISPOE DE 0:20MIN. PARA NEGAR A RESERVA"
                  , l_pulalinha_2, "  POR FALTA DE VEICULOS."
                  , l_pulalinha_2, " (011) 3366-3629 ", l_pulalinha_2

   if lr_param.adcsgrtaxvlr is not null and
      lr_param.adcsgrtaxvlr <> 0        then
      if lr_param.lcvcod = 2        and
         lr_param.lcvregprccod = 2  then

         let l_contatos = l_contatos clipped, "- A LOJA NAO OPERA COM TAXA DE ISENCAO NA PARTICIPACAO EM CASO DE SINISTRO"

      else

         let l_contatos = l_contatos clipped, " - A LOCADORA OFERECERA TAXA DE ISENCAO NA PARTICIPACAO EM CASO DE SINISTRO"
                                            , l_pulalinha_2
         let l_contatos = l_contatos clipped, "  (COBERTURA DE RISCO), OPTATIVA, AO CUSTO DE R$ ",
                            lr_param.adcsgrtaxvlr using  "<<<,<<&.&&", "/DIA."
      end if
   end if
       let l_contatos = l_contatos clipped, l_pulalinha_2

   let l_prorrogacoes = "_________________________________ PRORROGACOES _________________________________"
                     ,l_pulalinha_2
                     ,l_pulalinha_2
   for l_i = 1 to 50
      if am_cts36g01[l_i].aviprosoldat is null then
         let l_i = l_i - 1
         exit for
      end if

      let l_prorrogacoes = l_prorrogacoes clipped

      let l_prorrogacoes = l_prorrogacoes clipped, "==> EM ", am_cts36g01[l_i].aviprosoldat,
                           " AS ", am_cts36g01[l_i].aviprosolhor, l_pulalinha_2
      if am_cts36g01[l_i].aviprostt = "C"  then
         let l_prorrogacoes = l_prorrogacoes clipped, "   *** CANCELADA! ***"
      else
        let l_prorrogacoes = l_prorrogacoes clipped, " "
      end if

      let l_prorrogacoes = l_prorrogacoes clipped
               , "    DATA DE PRORROGACAO: ", am_cts36g01[l_i].vclretdat, l_pulalinha_2
               , "    HORA DE PRORROGACAO: ", am_cts36g01[l_i].vclrethor, l_pulalinha_2
               , "    PREVISAO DE USO....: ", am_cts36g01[l_i].aviprodiaqtd using "<<<<<<", " DIA(S)" , l_pulalinha_2

   end for

       if am_cts36g01[1].aviprosoldat is null then
          let l_prorrogacoes = l_prorrogacoes clipped, " NENHUMA.", l_pulalinha_2
       end if

   let l_xml =    "<report><serviceType>GENERATOR</serviceType>"clipped
              ,   "<typeOfConnection>xml</typeOfConnection>"clipped
              ,   "<fileSystem>",l_path_jasper clipped,"</fileSystem>"clipped
              ,   "<jasperFileName>faxPortoSocorro.jasper</jasperFileName>"clipped
              ,   "<outFileName>",l_fileName clipped,"</outFileName>"
              ,   "<outFileType>pdf</outFileType>"clipped
              ,   "<recordPath>/report/data/file</recordPath>"clipped
              ,   "<outbox>",l_path_output clipped,"</outbox>"clipped
              ,   "<generatorTIFF>false</generatorTIFF>"clipped
              ,   "<data>"
              ,      "<file>"
              ,         "<logo>",l_path_jasper clipped, l_logoemp clipped,"</logo>"
              ,         "<texto>"

              ,            l_pulalinha_2 clipped,l_pulalinha_2 clipped
              ,            l_pulalinha_2 clipped
              ,            l_pulalinha_2 clipped
              ,            l_dadosreserva clipped
              ,            l_pulalinha_2
              ,            l_pulalinha_2
              ,            l_dadoslocatario clipped
              ,            l_pulalinha_2
              ,            l_pulalinha_2
              ,            l_dadosveiculo clipped
              ,            l_pulalinha_2
              ,            l_pulalinha_2
              ,            l_observacoes clipped
              ,            l_pulalinha_2
              ,            l_consideracoes clipped
              ,            l_pulalinha_2
              ,            l_pulalinha_2
              ,            l_contatos clipped
              ,            l_pulalinha_2
              ,            l_pulalinha_2
              ,            l_prorrogacoes clipped

              ,         "</texto>"
              ,      "</file>"
              ,      "</data>"
              ,"</report>"

   initialize m_texto to null
   let m_texto = '<html><body>'  
               , l_pulalinha_22 clipped
               , '<p>', l_dadosreserva clipped, '</p>'
               , l_pulalinha_22
               , l_pulalinha_22
               , '<p>', l_dadoslocatario clipped, '</p>'
               , l_pulalinha_22
               , l_pulalinha_22
               , '<p>', l_dadosveiculo clipped, '</p>'
               , l_pulalinha_22
               , l_pulalinha_22
               , '<p>', l_observacoes clipped, '</p>'
               , l_pulalinha_22
               , '<p>', l_consideracoes clipped, '</p>'
               , l_pulalinha_22
               , l_pulalinha_22
               , '<p>', l_contatos clipped, '</p>'
               , l_pulalinha_22
               , l_pulalinha_22
          
          let m_acntip = 1
          let m_atdetpcod = 1
          
     if m_acntip = 1 and m_atdetpcod = 1 then
       
        call cts15m14_temp_resp(lr_param.atdsrvnum, lr_param.atdsrvano) returning l_result

        let m_texto = m_texto clipped
       	,"<p>- APOS O RECEBIMENTO DESTE, A LOCADORA PODERA RESPONDER A CONFIRMACAO DESTA"
        ," RESERVA ATE AS ", l_result, ", APOS ESTE HORARIO SOLICITACAO DE"
        ," RESERVA SERA CANCELADA.</p>"
        , "<p>- POR FAVOR RESPONDER DISPONIBILIDADE DA RESERVA: "
        , "<a href='https://wwws.portoseguro.com.br/pspsr/reserva/ReservaPortoSeguro.aspx?macsissgl=PSRONLINE&portal=2&"
        , "NumeroServico=", lr_param.atdsrvnum using '<<<<<<<<<<'
        , "&AnoServico=", lr_param.atdsrvano using '<<'
        , "&CodigoLocadora=", lr_param.lcvcod using '<<<<<<<<<<'
        , "'>CLICAR AQUI</a> PARA RESPONDER DISPONIBILIDADE."
        , "- APOS O RECEBIMENTO DESTE, A LOCADORA DISPOE DE 0:20MIN. PARA NEGAR A RESERVA"
        , "</p>"

     end if
               
     let m_texto = m_texto  clipped
         , '<p>', l_prorrogacoes clipped, '</p>'
         , '</body></html>'

#display 'l_xml ', l_xml clipped
#display '-------------------------------'
   if lr_fax.telefone <> 0 and
      lr_fax.telefone is not null then

   call figrc011RF_generatorfax(l_xml clipped
                               ,lr_fax.telefone
                               ,lr_fax.destinatario
                               ,lr_fax.notas
                               ,lr_fax.caminhoarq
                               ,"itcts15m14" #4glesttmp
                               ,false)
                                      returning lr_retornoFax.idFax,
                                                lr_retornoFax.codigoErro,
                                                lr_retornoFax.status,
                                                lr_retornoFax.mensagem,
                                                lr_retornoFax.sucesso
   whenever error continue
      if lr_retornoFax.status = 6 or lr_retornoFax.codigoErro = 0 then
         let l_tip = 2
         call cts10g01_sit_fax(l_tip,"RS", lr_param.faxch1, lr_param.faxch2)
      else
         if lr_retornoFax.status = 5 then
            let l_tip = 1
            call cts10g01_sit_fax(l_tip,"RS", lr_param.faxch1, lr_param.faxch2)
         end if
      end if

      select 1
       from iddkdominio
       where cponom = 'PSOATLUSRPOR'
        and cpodes = g_issk.funmat
      if sqlca.sqlcode = 0 then
         display 'lr_retornoFax.idFax,     : ',lr_retornoFax.idFax
         display 'lr_retornoFax.codigoErro,: ',lr_retornoFax.codigoErro
         display 'lr_retornoFax.status,    : ',lr_retornoFax.status
         display 'lr_retornoFax.mensagem,  : ',lr_retornoFax.mensagem clipped
         display 'lr_retornoFax.sucesso    : ',lr_retornoFax.sucesso
      end if


      call figrc011RF_consultafax(lr_retornoFax.idFax)
                                 returning lr_retornoConFax.idFax,
                                           lr_retornoConFax.status,
                                           lr_retornoConFax.codigoErro,
                                           lr_retornoConFax.mensagem,
                                           lr_retornoConFax.sucesso
      if lr_retornoConFax.status = 6 or lr_retornoConFax.codigoErro = 0 then
         let l_tip = 2
         call cts10g01_sit_fax(l_tip,"RS", lr_param.faxch1, lr_param.faxch2)
      else
         if lr_retornoConFax.status = 5 then
            let l_tip = 1
            call cts10g01_sit_fax(l_tip,"RS", lr_param.faxch1, lr_param.faxch2)
         end if
      end if
   whenever error stop
   end if

end function

