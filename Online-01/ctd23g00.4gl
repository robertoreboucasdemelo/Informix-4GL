# Sistema.......: Porto Socorro                                               #
# Modulo........: ctd23g00                                                    #
# Analista Resp.: Kevellin Olivatti                                           #
# PSI...........: 214566                                                      #
# Objetivo......: Buscar e gravar informações das controladoras               #
#.............................................................................#
# Desenvolvimento: Kevellin Olivatti                                          #
# Liberacao......:                                                            #
#.............................................................................#
#                                                                             #
#                        * * * Alteracoes * * *                               #
#                                                                             #
# Data      Autor Fabrica PSI     Alteracao                                   #
# --------  ------------- ------  --------------------------------------------#
# 23/12/08  Fabio Costa   214566  Incluir total de viaturas logadas e ativas  #
# 08/06/10  Raji	          Correçao do Total de MDTs que enviaram sinal#
# 15/06/10  Raji	          Correçao das quantidades de mensagens       #
#                                 Pendentes,Enviados e com Falhas (stt errado)#
#-----------------------------------------------------------------------------#

database porto

   define m_prep_sql smallint

#---------------------------
function ctd23g00_prepare()
#---------------------------

   define l_sql char(1000)

   let l_sql =  'select a.mdtmvtstt, b.mdtctrcod, count(*) ',
                '  from datmmdtmvt a, datkmdt b ',
                ' where a.caddat = ? ',
                '   and a.mdtcod =  b.mdtcod ',
                '   and a.cadhor <= current - 2 units minute ', ## com 2 minutos de processamento
                '   and a.mdtmvtstt = 1 ',
                ' group by a.mdtmvtstt, b.mdtctrcod ',
                ' union ',
                'select a.mdtmvtstt, b.mdtctrcod, count(*) ',
                '  from datmmdtmvt a, datkmdt b ',
                ' where a.caddat = ? ',
                '   and a.mdtcod = b.mdtcod ',
                '   and a.cadhor <= current - 2 units minute ', ## com 2 minutos de processamento
                '   and a.cadhor >= current - 4 units minute ',
                '   and a.mdtmvtstt <> 1 ',
                '  group by a.mdtmvtstt, b.mdtctrcod '
   prepare pctd23g00011 from l_sql
   declare cctd23g00011 cursor for pctd23g00011

   let l_sql =  ' select a.mdtmsgstt, b.mdtctrcod, count(*) ',
                '   from datmmdtmsg a, datkmdt b, datmmdtlog c, outer datmmdtsrv d ',
                '   where c.atldat = ? ',
                '     and a.mdtcod = b.mdtcod ',
                '     and c.mdtmsgnum  =  a.mdtmsgnum ',
                '     and c.mdtlogseq  =  1 ',
                '     and d.mdtmsgnum  =  a.mdtmsgnum ',
                '     and c.atlhor    <= current - 2 units minute ', ## com 2 minutos de processamento
                '     and a.mdtmsgstt in (1,2) ',
                '   group by a.mdtmsgstt, b.mdtctrcod ',
                '   union ',
                '  select a.mdtmsgstt, b.mdtctrcod, count(*) ',
                '    from datmmdtmsg a, datkmdt b, datmmdtlog c, outer datmmdtsrv d ',
                '   where c.atldat = ? ',
                '     and a.mdtcod = b.mdtcod ',
                '     and c.mdtmsgnum  =  a.mdtmsgnum ',
                '     and c.mdtlogseq  =  1 ',
                '     and d.mdtmsgnum  =  a.mdtmsgnum ',
                '     and c.atlhor <= current - 2 units minute ', ## Pega mensagens de 5 minutos
                '     and c.atlhor >= current - 7 units minute ', ## com 2 minutos de processamento
                '     and a.mdtmsgstt not in (1,2) ',
                '   group by a.mdtmsgstt, b.mdtctrcod '
   prepare pctd23g00016 from l_sql
   declare cctd23g00016 cursor for pctd23g00016

   let l_sql = 'insert into datkmdtsit ',
                ' ( atlhordat, ',
                  ' mdtctrcod, ',
                  ' pndsnsqtd, ',
                  ' prcsnsqtd, ',
                  ' pndmsgqtd, ',
                  ' prcmsgqtd, ',
                  ' errmsgqtd, ',
                  ' logvtrtot, ',
                  ' atvvtrtot  ) ',
                ' values (?,?,?,?,?,?,?,?,?) '
   prepare pctd23g00018 from l_sql

   let l_sql =  ' select atlhordat  ',
                '   from datkmdtsit ',
                '  where atlhordat = ? '
   prepare pctd23g00022 from l_sql
   declare cctd23g00022 cursor for pctd23g00022

   # Total de MDTs que estao logados nas controladoras
   let l_sql = ' select m.mdtctrcod, count (distinct m.mdtcod) mdts ',
               ' from datkveiculo v, dattfrotalocal f, datkmdt m, dpaksocor s ',
               ' where v.socvclcod = f.socvclcod ',
               '   and v.mdtcod    = m.mdtcod ',
               '   and v.pstcoddig = s.pstcoddig ',
               '   and f.c24atvcod not in ("QTP", "NIL") ',
               '   and v.socacsflg    = "0" ',
               '   and v.socoprsitcod = "1" ',     # Situacao ATIVO
               '   and s.frtrpnflg   != "2" ',     # dif. "Demais areas"
               ' group by m.mdtctrcod ',
               ' order by m.mdtctrcod '
   prepare p_mdt_logado from l_sql
   declare c_mdt_logado cursor for p_mdt_logado

   # Total de MDTs que enviaram sinal
   let l_sql = ' select b.mdtctrcod, count (distinct b.mdtcod) mdts ',
               ' from datmmdtmvt a, datkmdt b, datkveiculo v, dattfrotalocal f, dpaksocor s',
               ' where a.caddat = today ',
               '   and a.mdtcod = b.mdtcod ',
               '   and a.cadhor <= current ',
               '   and a.cadhor >= current - 5 units minute ',
               '   and v.mdtcod  = a.mdtcod ',
               '   and v.pstcoddig = s.pstcoddig ',
               '   and v.socvclcod = f.socvclcod ',
               '   and f.c24atvcod not in ("QTP", "NIL") ',
               '   and v.socacsflg    = "0" ',
               '   and v.socoprsitcod = "1" ',     # Situacao ATIVO
               '   and s.frtrpnflg   != "2" ',     # dif. "Demais areas"
               ' group by b.mdtctrcod ',
               ' order by b.mdtctrcod '
   prepare p_mdt_ativo from l_sql
   declare c_mdt_ativo cursor for p_mdt_ativo

   let m_prep_sql = true

end function

#-------------------------------------------
function ctd23g00_formatar_datahora(param)
#-------------------------------------------

   define param record
       data_atual   date,
       hora_atual   datetime hour to minute
   end record

   define l_data_hora_c  char(19),
          l_data_hora    datetime year to minute

   #Formatação da data(datetime year to minute)
   let l_data_hora_c = null
   let l_data_hora_c = param.data_atual, " ", param.hora_atual
   let l_data_hora_c = l_data_hora_c[7,10], "-",  # ANO
                       l_data_hora_c[4,5],  "-",  # MES
                       l_data_hora_c[1,2],  " ",  # DIA
                       l_data_hora_c[12,16]

   let l_data_hora = l_data_hora_c

   return l_data_hora

end function


#Gravar informações das controladoras
#-------------------------------------------
function ctd23g00_gravar_inf_ctr(param)
#-------------------------------------------
   define param record
       data_atual datetime year to minute
   end record

   define sinais record
       mdtmvtstt like datmmdtmvt.mdtmvtstt,
       mdtctrcod like datkmdt.mdtctrcod,
       quantidade integer,
       atlhordat datetime year to minute
   end record

   define mensagens record
          mdtmsgstt  like datmmdtmsg.mdtmsgstt,
          mdtctrcod  like datkmdt.mdtctrcod,
          quantidade integer,
          atlhordat  datetime year to minute
   end record

   define lr_retorno record
          erro      smallint,
          mensagem  char(100)
   end record

   define l_mdt record
          mdtctrcod  smallint ,
          mdts       integer
   end record

   define ctrsit array[15] of record
          pndsnsqtd  like datkmdtsit.pndsnsqtd,
          prcsnsqtd  like datkmdtsit.prcsnsqtd,
          pndmsgqtd  like datkmdtsit.pndmsgqtd,
          prcmsgqtd  like datkmdtsit.prcmsgqtd,
          errmsgqtd  like datkmdtsit.errmsgqtd,
          logvtrtot  like datkmdtsit.logvtrtot,
          atvvtrtot  like datkmdtsit.atvvtrtot
   end record

   define l_mdtctrcod integer

   initialize lr_retorno.* to null

   for l_mdtctrcod = 1 to 15
       let ctrsit[l_mdtctrcod].pndsnsqtd = 0
       let ctrsit[l_mdtctrcod].prcsnsqtd = 0
       let ctrsit[l_mdtctrcod].pndmsgqtd = 0
       let ctrsit[l_mdtctrcod].prcmsgqtd = 0
       let ctrsit[l_mdtctrcod].errmsgqtd = 0
       let ctrsit[l_mdtctrcod].logvtrtot = 0
       let ctrsit[l_mdtctrcod].atvvtrtot = 0
   end for

   if m_prep_sql is null or
     m_prep_sql <> true then
     call ctd23g00_prepare()
   end if

   let lr_retorno.mensagem = "Execucao ctd23g00 ok"
   let lr_retorno.erro = 1

   #Verifica se já existem dados das mensagens para o mesmo minuto
   let mensagens.atlhordat =  null
   open cctd23g00022 using param.data_atual
   fetch cctd23g00022 into mensagens.atlhordat
   close cctd23g00022

   if mensagens.atlhordat is not null then
       let lr_retorno.erro = 4
       let lr_retorno.mensagem = 'Ha informacoes na tabela para o mesmo minuto '
                                 , param.data_atual
       return lr_retorno.*
   end if


   # buscar info do total de MDTs antes de tratar os sinais
   foreach c_mdt_logado into l_mdt.*
      let l_mdtctrcod = l_mdt.mdtctrcod
      let ctrsit[l_mdtctrcod].logvtrtot = l_mdt.mdts
   end foreach

   foreach c_mdt_ativo into l_mdt.*
      let l_mdtctrcod = l_mdt.mdtctrcod
      let ctrsit[l_mdtctrcod].atvvtrtot = l_mdt.mdts
   end foreach

   #Busca situação das controladoras - mensagens
   whenever error continue
   open cctd23g00016 using param.data_atual,
                           param.data_atual
   whenever error stop

   foreach cctd23g00016 into mensagens.mdtmsgstt,
                             l_mdtctrcod,
                             mensagens.quantidade

      # mensagens enviadas
      if mensagens.mdtmsgstt = 0 or      # TRANSMITIDA OK
         mensagens.mdtmsgstt = 4 or      # TEMPO QRU-RECEB ESGOTADO (ja transmitida)
         mensagens.mdtmsgstt = 6 then    # RECEBIDA OK
         let ctrsit[l_mdtctrcod].prcmsgqtd = ctrsit[l_mdtctrcod].prcmsgqtd + mensagens.quantidade
      end if
      
      # mensagens pendentes
      if mensagens.mdtmsgstt = 1 or      # AGUARDANDO TRANSMISSAO
         mensagens.mdtmsgstt = 2 then    # AGUARDANDO RETRANSMISSAO
         let ctrsit[l_mdtctrcod].pndmsgqtd = ctrsit[l_mdtctrcod].pndmsgqtd + mensagens.quantidade
      end if
   
       # mensagens com erro
      if mensagens.mdtmsgstt = 3 then    # ERRO DE TRANSMISSAO
         let ctrsit[l_mdtctrcod].errmsgqtd = ctrsit[l_mdtctrcod].errmsgqtd + mensagens.quantidade
      end if
      
      # mensagens cancelas (NAO IMPLEMENTADO)
      #if mensagens.mdtmsgstt = 5 then   # TRANSMISSAO CANCELADA
      #   let ctrsit[l_mdtctrcod].? = ctrsit[l_mdtctrcod].? + mensagens.quantidade
      #end if

   end foreach

   open cctd23g00011 using param.data_atual,
                           param.data_atual
   whenever error stop

   foreach cctd23g00011 into sinais.mdtmvtstt,
                             l_mdtctrcod,
                             sinais.quantidade

      if sinais.mdtmvtstt = 1  then # Sinais Pendentes
         let ctrsit[l_mdtctrcod].pndsnsqtd = ctrsit[l_mdtctrcod].pndsnsqtd + sinais.quantidade
      else  # Sinais Processados
         let ctrsit[l_mdtctrcod].prcsnsqtd = ctrsit[l_mdtctrcod].prcsnsqtd + sinais.quantidade
      end if

   end foreach

   for l_mdtctrcod = 1 to 15

      if (ctrsit[l_mdtctrcod].pndsnsqtd +
          ctrsit[l_mdtctrcod].prcsnsqtd +
          ctrsit[l_mdtctrcod].pndmsgqtd +
          ctrsit[l_mdtctrcod].prcmsgqtd +
          ctrsit[l_mdtctrcod].errmsgqtd +
          ctrsit[l_mdtctrcod].logvtrtot +
          ctrsit[l_mdtctrcod].atvvtrtot) > 0 then

          # Grava informacoes
          execute pctd23g00018 using param.data_atual,
                                     l_mdtctrcod,
                                     ctrsit[l_mdtctrcod].pndsnsqtd,
                                     ctrsit[l_mdtctrcod].prcsnsqtd,
                                     ctrsit[l_mdtctrcod].pndmsgqtd,
                                     ctrsit[l_mdtctrcod].prcmsgqtd,
                                     ctrsit[l_mdtctrcod].errmsgqtd,
                                     ctrsit[l_mdtctrcod].logvtrtot,
                                     ctrsit[l_mdtctrcod].atvvtrtot

          if sqlca.sqlcode <> 0 then
             let lr_retorno.erro = 3
             let lr_retorno.mensagem = 'ERRO gravar_inf_controladora ', sqlca.sqlcode
                                       , ' no insert pctd23g00018'
             return lr_retorno.*
          end if

      end if
   end for

   return lr_retorno.*

end function