#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema        : Teleatendimento/Porto Socorro                               #
# Modulo         : ctb00g06                                                    #
# Analista.Resp  : Carlos Zyon                                                 #
# PSI            : 188603                                                      #
# Objetivo       : Qualifica a pontualidade do servico                         #
#..............................................................................#
# Desenvolvimento: Adriana Schneider - Fabrica de Software  -Meta              #
# Liberacao      : 06/04/2005                                                  #
#..............................................................................#
#                    * * * Alteracoes * * *                                    #
#                                                                              #
#   Data      Autor Fabrica Origem      Alteracao                              #
# ----------  ------------- ---------   ---------------------------------------#
# 24/09/2010  Fabio Costa   PSI 258610  Revisao de calculo, incluir tolerancia #
#                                       erro select base considera qualificado #
#------------------------------------------------------------------------------#
database porto

define m_prep smallint

#----------------------------------------------------------------
function ctb00g06_prep()
#----------------------------------------------------------------

  define l_sql char(1000)

  let l_sql = " select c.mdtcod   , a.atdprvdat, d.lclltt, d.lcllgt, ",
              "        b.atdetpdat, b.atdetphor, d.ufdcod, d.cidnom, ",
              "        a.atddatprg, a.atdhorprg, a.atdhorpvt, ",
              "        a.atdlibdat, a.atdlibhor ",
              " from   datmservico a,  ",
              "        datkveiculo c,  ",
              "        datmsrvacp  b,  ",
              "        datmlcl     d   ",
              " where b.atdetpcod in (3,4) and                ",
              "       b.atdsrvseq  = (select max(atdsrvseq)   ",
              "                       from datmsrvacp  e       ",
              "                       where a.atdsrvnum = e.atdsrvnum  and ",
              "                             a.atdsrvano = e.atdsrvano) and ",
              "       a.atdsrvnum = b.atdsrvnum  and ",
              "       a.atdsrvano = b.atdsrvano  and ",
              "       b.socvclcod = c.socvclcod  and ",
              "       a.atdsrvnum = d.atdsrvnum  and ",
              "       a.atdsrvano = d.atdsrvano  and ",
              "       d.c24endtip = 1            and ",
              "       a.atdsrvnum = ?            and ",
              "       a.atdsrvano = ?  "
  prepare pctb00g06001 from l_sql
  whenever error continue
  declare cctb00g06001 cursor for pctb00g06001
  whenever error stop

  if sqlca.sqlcode <> 0 then
     display "Erro cctb00g06001:",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
     return 1
  end if

  let l_sql = " select b.atldat,b.atlhor             ",
              " from   datmmdtsrv a,datmmdtlog b     ",
              " where  a.atdsrvnum =  ?          and ",
              "        a.atdsrvano =  ?          and ",
              "        a.mdtmsgnum = b.mdtmsgnum and ",
              "        b.mdtmsgstt in (0,6,4)        ",## 0=Transmitida ou
              " order by 1 desc, 2 desc"               ## 6=Recebida ou
                                                       ## 4=Tempo Esgotado
  prepare pctb00g06002 from l_sql
  whenever error continue
  declare cctb00g06002 cursor for pctb00g06002
  whenever error stop

  if sqlca.sqlcode <> 0 then
     display "Erro cctb00g06002:",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
     return 1
  end if

  let l_sql = " select caddat,cadhor,lclltt,lcllgt  ",
              " from  datmmdtmvt                    ",
              " where atdsrvnum    = ?  and ",
              "       atdsrvano    = ?  and ",
              "       mdtmvtstt    = 2  and ",## Apenas Status 2=Processado OK
              "       mdtmvttipcod = 2  and ",## Apenas Tipo de Movimento = Botao
              "       mdtbotprgseq = 2      " ## Apenas QRU-INI
  prepare pctb00g06003 from l_sql
  whenever error continue
  declare cctb00g06003 cursor for pctb00g06003
  whenever error stop

  if sqlca.sqlcode <> 0 then
     display "Erro cctb00g06003:",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
     return 1
  end if

  let l_sql  = "select srv.atdsrvnum, srv.atdsrvano ",
              " from datmservico srv, ",
                   " datmsrvacp  acp ",
             " where srv.atdetpcod in (3,4) ",
               " and srv.atdsrvseq = acp.atdsrvseq ",
               " and srv.atdsrvnum = acp.atdsrvnum ",
               " and srv.atdsrvano = acp.atdsrvano ",
               " and acp.atdetpdat >= ? ",
               " and acp.atdetpdat <= ? ",
               " and acp.pstcoddig = ?  ",
               " and acp.srrcoddig  = ? "

  prepare pctb00g06004 from l_sql
  whenever error continue
  declare cctb00g06004 cursor for pctb00g06004
  whenever error stop

  if sqlca.sqlcode <> 0 then
     display "Erro cctb00g06004:",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
     return 1
  end if

  let m_prep = true

  # display "Pontual", "	",
  #         "Numero do servico", "	",
  #         ##"Ano do servico", "	",
  #         "Codigo do MDT", "	",
  #         ##"UF ocorrencia","	",
  #         "Cidade ocorrencia", "	",
  #         ##"Latitude ocorrencia", "	",
  #         ##"Longitude ocorrencia", "	",
  #         "Data+Hora do acionamento", "	",
  #         "Previsao do sistema", "	",
  #         ##"Data+Hora da transmissao ok", "	",
  #         "Data+Hora prevista (QTR)/Programacao", "	",
  #         "Data+Hora do QRU-INI", "	",
  #         ##"Distancia QRU-INI - Ocorrencia", "	",
  #         ##"Latitude do QRU-INI", "	",
  #         ##"Longitude do QRU-INI", "	",
  #         "Codigo erro", "	",
  #         "Mensagem erro", "	",
  #         "Qualificado", "	"

  return 0

end function

#----------------------------------------------------------------
function ctb00g06_qualifpont(lr_param)
#----------------------------------------------------------------
  define lr_param record
         atdsrvnum     like datmservico.atdsrvnum, ## Numero do servico
         atdsrvano     like datmservico.atdsrvano, ## Ano do servico
         prtbnfgrpcod  integer
  end record

  define l_ret record
         coderro      integer ,  ## Codigo erro retorno / 0=Ok <>0=Error
         msgerro      char(100), ## Mensagem erro retorno
         qualificado  char(01)   ## Sim ou Nao
  end record

  define l_trab record
         mdtcod       like datkveiculo.mdtcod    ,     # Codigo do MDT
         atdetpdat    like datmsrvacp.atdetpdat  ,     # Data do acionamento
         atdetphor    like datmsrvacp.atdetphor  , #####nterval hour to minute, ## Hora do acionamento
         atdprvdat    interval hour to minute    ,     # Previsao do sistema
         datahoraqtr  datetime year to minute    ,     # Data+Hora prevista (QTR)
         datahoratmp  datetime year to minute    ,
         orilclltt    like datmlcl.lclltt        ,     # Latitude origem
         orilcllgt    like datmlcl.lcllgt        ,     # Longitude origem
         atldat       like datmmdtlog.atldat     ,     # Data do recebimento da msg
         atlhor       like datmmdtlog.atlhor     ,     # Hora do recebimento da msg
         caddat       like datmmdtmvt.caddat     ,     # Data do QRU-INI
         cadhor       datetime hour to minute    ,     # Hora do QRU-INI
         dtahoraqru   datetime year to minute    ,     # Data+Hora do QRU-INI
         srvlclltt    like datmmdtmvt.lclltt     ,     # Latitude do QRU-INI
         srvlcllgt    like datmmdtmvt.lcllgt     ,     # Longitude do QRU-INI
         dstqtd       dec(8,4)                   ,     # Distancia
         txtdathor    char(20)                   ,     # Usado nas convercoes
         ufdcod       like datmlcl.ufdcod        ,     # UF do local de ocorrencia
         cidnom       like datmlcl.cidnom        ,     # Cidade da ocorrencia
         atddatprg    like datmservico.atddatprg ,     # Data da programacao
         atdhorprg    like datmservico.atdhorprg ,     # Hora da programacao
         datahoraacn  datetime year to minute    ,     # Data+Hora acionamento do SRV
         atdhorpvt    interval hour to minute    ,     # Previsao do cliente
         atdhorpvt_c  char(10) ,
         srvhorpvt    datetime year to minute    ,
         inthorpvt    interval hour to minute    ,
         txtaux01     char(20)                   ,
         atdlibdat    like datmservico.atdlibdat ,     # Data da liberacao
         atdlibhor    like datmservico.atdlibhor       # Hora da liberacao
  end record

  define l_interv record
         prvitv      interval minute(04) to minute ,  # intervalo acionamento/previsao
         atditv      interval minute(04) to minute ,  # intervalo acionamento/atendimento
         txt         char(5)                       ,  # variavel p/ cast interval to integer
         prvint      decimal(8,0)                  ,  # interv previsao em integer
         prvtol      decimal(10,2)                 ,  # interv previsao + tolerancia
         atdint      integer                       ,  # interv atendimento em integer
         extra       integer                       ,  # tempo extra em relacao ao previsto
         extprc      decimal(5,2)                  ,  # tempo extra em %
         toler       decimal(5,2)                  ,  # tolerancia cadastrada para o criterio
         hortomin01  interval hour to minute       ,
         hortomin02  interval hour to minute       ,
         hortosec03  interval hour to second       ,
         hortomin03  interval hour to minute
  end record

  define lr_retorno      smallint ,
         l_atdprvdat_c  char(10) ,
         l_msginf       char(100),
         l_msgdst       char(30) ,
         l_retcod       integer

  ## Inicializa variaveis
  initialize l_trab.*, l_interv.*, l_ret.* to null

  let l_ret.coderro     = 99
  let l_ret.msgerro     = ""
  let l_ret.qualificado = "N"
  let l_atdprvdat_c     = null
  let l_msginf          = null
  let l_msgdst          = null

  if m_prep is null or
     m_prep <> true then
     let lr_retorno = ctb00g06_prep()
     if lr_retorno <> 0
        then
        display "Pontualidade erro prepares: ", sqlca.sqlcode
        let l_ret.msgerro = "Pontualidade erro ao acessar base de dados: ", sqlca.sqlcode
        return 0, l_ret.msgerro, "S"
     end if
  end if

  display 'PONTUALIDADE:'

  ## Recupera o codigo do MDT, a previsao e as coordenadas da origem
  open cctb00g06001 using lr_param.atdsrvnum,lr_param.atdsrvano
  whenever error continue
  fetch cctb00g06001 into l_trab.mdtcod    ,
                          l_atdprvdat_c    ,
                          l_trab.orilclltt ,
                          l_trab.orilcllgt ,
                          l_trab.atdetpdat ,
                          l_trab.atdetphor ,
                          l_trab.ufdcod    ,
                          l_trab.cidnom    ,
                          l_trab.atddatprg ,
                          l_trab.atdhorprg ,
                          l_trab.atdhorpvt_c ,
                          l_trab.atdlibdat ,
                          l_trab.atdlibhor
  whenever error stop

  if sqlca.sqlcode <> 0 then

     let l_ret.msgerro = "Erro ao selecionar coordenadas do local do servico(ctb00g06): ", sqlca.sqlcode

     # if sqlca.sqlcode <> 100 then
     #    let l_ret.coderro = sqlca.sqlcode
     # end if

     display "Pontualidade erro: ", "	",
             lr_param.atdsrvnum using "<<<<<<<<<", "	",
             ##lr_param.atdsrvano using "<<", "	",
             l_trab.mdtcod using "<<<<<<", "	",
             ##l_trab.ufdcod clipped,"	",
             l_trab.cidnom clipped,"	",
             ##l_trab.orilclltt, "	",
             ##l_trab.orilcllgt, "	",
             l_trab.atdetpdat using "yyyy-mm-dd"," ", l_trab.atdetphor, "	",
             l_atdprvdat_c clipped, "	",
             ##l_trab.atldat using "yyyy-mm-dd"," ", l_trab.atlhor, "	",
             l_trab.datahoraqtr, "	",
             l_trab.dtahoraqru, "	",
             #l_trab.dstqtd, "	",
             #l_trab.srvlclltt, "	",
             #l_trab.srvlcllgt, "	",
             l_ret.coderro using "<<<<<<", "	",
             l_ret.msgerro clipped, "	",
             l_ret.qualificado, "	"

     return 0, l_ret.msgerro, "S"
  end if

  ## Converter de char para interval
  let l_trab.atdprvdat = l_atdprvdat_c

  ## Caso nao exista previsao assumir 00:20 como tempo padrao
  if l_trab.atdprvdat is null then
     let l_trab.atdprvdat = "00:20"
  end if

  ## Caso a previsao inferior a 00:10 assumir 00:10 como tempo minimo
  if l_trab.atdprvdat < "00:10" then
     let l_trab.atdprvdat = "00:10"
  end if

  ## Recupera a data e hora do recebimento da mensagem do servico para identificar ultima mensagem
  open cctb00g06002 using lr_param.atdsrvnum,lr_param.atdsrvano
  whenever error continue
  fetch cctb00g06002 into l_trab.atldat, l_trab.atlhor
  whenever error stop

  if sqlca.sqlcode <> 0 then

     let l_ret.msgerro = "Erro ao selecionar data/hora da ultima mensagem enviada(ctb00g06): ", sqlca.sqlcode

     # if sqlca.sqlcode <> 100 then
     #    let l_ret.coderro = sqlca.sqlcode
     # end if

     display "Pontualidade erro: ", "	",
             lr_param.atdsrvnum using "<<<<<<<<<<", "	",
             ##lr_param.atdsrvano using "<<", "	",
             l_trab.mdtcod using "<<<<<", "	",
             ##l_trab.ufdcod clipped,"	",
             l_trab.cidnom clipped,"	",
             #l_trab.orilclltt, "	",
             #l_trab.orilcllgt, "	",
             l_trab.atdetpdat using "yyyy-mm-dd"," ", l_trab.atdetphor, "	",
             l_trab.atdprvdat, "	",
             ##l_trab.atldat using "yyyy-mm-dd"," ", l_trab.atlhor, "	",
             l_trab.datahoraqtr, "	",
             l_trab.dtahoraqru, "	",
             #l_trab.dstqtd, "	",
             #l_trab.srvlclltt, "	",
             #l_trab.srvlcllgt, "	",
             l_ret.coderro using "<<<<<<", "	",
             l_ret.msgerro clipped, "	",
             l_ret.qualificado, "	"

     return 0, l_ret.msgerro, "S"
  end if

  ## Monta data e hora do qtr
  if l_trab.atddatprg is not null  # servico tem horario programado
     then
     let l_trab.txtdathor  = l_trab.atddatprg using "yyyy-mm-dd", " ", l_trab.atdhorprg
     let l_trab.txtdathor  = l_trab.txtdathor[1,16]
     let l_trab.datahoraqtr = l_trab.txtdathor

     display 'Prev. program: ', l_trab.datahoraqtr

  else   # servico tem data/hora calculada pelo sistema

     let l_trab.txtdathor = null
     let l_trab.srvhorpvt = null
     let l_trab.txtaux01  = null

     let l_trab.txtdathor   = l_trab.atldat using "yyyy-mm-dd", " ", l_trab.atlhor
     let l_trab.txtdathor   = l_trab.txtdathor[1,16]
     let l_trab.datahoratmp = l_trab.txtdathor

     # previsao do sistema + data/hora da ultima mensagem
     let l_trab.datahoraqtr = l_trab.datahoratmp + l_trab.atdprvdat

     # horario da previsao cliente, a partir da hora da liberacao
     initialize l_trab.txtdathor, l_trab.datahoratmp to null

     let l_trab.txtdathor   = l_trab.atdlibdat using "yyyy-mm-dd", " ", l_trab.atdlibhor
     let l_trab.txtdathor   = l_trab.txtdathor[1,16]
     let l_trab.datahoratmp = l_trab.txtdathor

     # previsao cliente + data/hora da liberacao
     let l_trab.atdhorpvt = l_trab.atdhorpvt_c

     let l_trab.srvhorpvt = l_trab.datahoratmp + l_trab.atdhorpvt

     # display 'l_trab.datahoratmp: ', l_trab.datahoratmp
     # display 'l_trab.atdhorpvt..: ', l_trab.atdhorpvt

     display 'Prev. sistema: ', l_trab.datahoraqtr
     display 'Prev. cliente: ', l_trab.srvhorpvt

     # conta o QTR pela maior previsao
     if l_trab.srvhorpvt is not null and
        l_trab.srvhorpvt > l_trab.datahoraqtr
        then
        let l_trab.datahoraqtr = l_trab.srvhorpvt
     end if
  end if

  display 'QTR maximo...: ', l_trab.datahoraqtr

  ## Recupera a data, hora e coordenadas do inicio do servico
  open cctb00g06003 using lr_param.atdsrvnum,lr_param.atdsrvano
  whenever error continue
  fetch cctb00g06003 into l_trab.caddat,
                          l_trab.cadhor,
                          l_trab.srvlclltt,
                          l_trab.srvlcllgt
  whenever error stop

  if sqlca.sqlcode <> 0 then

     let l_ret.msgerro = "Erro ao selecionar data/hora inicio do servico(ctb00g06): ", sqlca.sqlcode

     # if sqlca.sqlcode <> 100 then
     #    let l_ret.coderro = sqlca.sqlcode
     # end if

     display "Pontualidade erro: ", "	",
             lr_param.atdsrvnum using "<<<<<<<<<", "	",
             ##lr_param.atdsrvano using "<<", "	",
             l_trab.mdtcod using "<<<<<<", "	",
             ##l_trab.ufdcod clipped,"	",
             l_trab.cidnom clipped,"	",
             #l_trab.orilclltt, "	",
             #l_trab.orilcllgt, "	",
             l_trab.atdetpdat using "yyyy-mm-dd"," ", l_trab.atdetphor, "	",
             l_trab.atdprvdat, "	",
             ##l_trab.atldat using "yyyy-mm-dd"," ", l_trab.atlhor, "	",
             l_trab.datahoraqtr, "	",
             l_trab.dtahoraqru, "	",
             #l_trab.dstqtd, "	",
             #l_trab.srvlclltt, "	",
             #l_trab.srvlcllgt, "	",
             l_ret.coderro using "<<<<<", "	",
             l_ret.msgerro clipped, "	",
             l_ret.qualificado, "	"

     return 0, l_ret.msgerro, "S"
  end if

  # monta data/hora do acionamento (adicionada da data/hora utl mensagem)
  initialize l_trab.txtdathor to null

  # let l_trab.txtdathor  = l_trab.atdetpdat using "yyyy-mm-dd", " ", l_trab.atdetphor
  let l_trab.txtdathor   = l_trab.atldat using "yyyy-mm-dd", " ", l_trab.atlhor
  let l_trab.datahoraacn = l_trab.txtdathor[1,16]

  ## Monta data e hora do qru-ini
  let l_trab.txtdathor  = l_trab.caddat using "yyyy-mm-dd", " ", l_trab.cadhor
  let l_trab.dtahoraqru = l_trab.txtdathor

  display 'Acionamento..: ', l_trab.datahoraacn
  display 'QRU-INI......: ', l_trab.dtahoraqru

  let l_msgdst = "N/D"

  ## Calcula distancia entre local do servico e local do veiculo
  let l_trab.dstqtd = cts18g00(l_trab.orilclltt,
                               l_trab.orilcllgt,
                               l_trab.srvlclltt,
                               l_trab.srvlcllgt)

  if l_trab.orilclltt = 0 or l_trab.orilclltt is null or
     l_trab.orilcllgt = 0 or l_trab.orilcllgt is null or
     l_trab.srvlclltt = 0 or l_trab.srvlclltt is null or
     l_trab.srvlcllgt = 0 or l_trab.srvlcllgt is null
     then
     let l_trab.dstqtd = 0
     let l_msgdst = "Sem Localizacao"
  else
     let l_msgdst = l_trab.dstqtd * -1000 using "<<<<<<<<#", "m"
  end if

  display 'DISTANCIA....: ', l_msgdst

  ## Se QRU > previsao + margem de tolerancia, desqualifica a pontualidade
  let l_interv.prvitv = l_trab.datahoraqtr - l_trab.datahoraacn
  let l_interv.atditv = l_trab.dtahoraqru  - l_trab.datahoraacn

  let l_interv.txt = l_interv.prvitv
  let l_interv.prvint = l_interv.txt

  let l_interv.txt = l_interv.atditv
  let l_interv.atdint = l_interv.txt

  let l_interv.extra = l_interv.atdint - l_interv.prvint
  let l_interv.extprc = (l_interv.extra / l_interv.prvint) * 100

  call ctb00g06_obter_tolerancia(lr_param.prtbnfgrpcod)
       returning l_retcod, l_ret.msgerro, l_interv.toler

  # QTR previsto + Tolerancia X QTR Cumprido / Posicao QRU INI
  # 00:30 + 20.0% = 00:36 X 00:40 / 549m

  let l_interv.hortomin01 = l_interv.prvitv
  let l_interv.hortomin02 = l_interv.atditv

  if l_interv.toler is not null and l_interv.toler > 0
     then
     let l_interv.prvtol = l_interv.prvint + ((l_interv.prvint * l_interv.toler) / 100)
  else
     let l_interv.toler  = 0
     let l_interv.prvtol = l_interv.prvint
  end if

  display 'Prev + toler.: ', l_interv.prvtol

  call ctb00g15_mindectoitvhs(l_interv.prvtol)
       returning l_interv.hortosec03

  let l_interv.hortomin03 = l_interv.hortosec03

  let l_msginf = l_interv.hortomin01, '  + ', l_interv.toler, '%  = ',
                 l_interv.hortomin03, "   X ",
                 l_interv.hortomin02, ' / ', l_msgdst clipped

  let l_ret.msgerro = l_msginf clipped

  # Se distancia > 300m, desqualifica a pontualidade
  if l_trab.dstqtd > 0.300 then
     display "Pontualidade nao qualificada(01): ", "	",
             lr_param.atdsrvnum using "<<<<<<<<<", "	",
             ##lr_param.atdsrvano using "<<", "	",
             l_trab.mdtcod using "<<<<<<", "	",
             ##l_trab.ufdcod clipped,"	",
             l_trab.cidnom clipped,"	",
             #l_trab.orilclltt, "	",
             #l_trab.orilcllgt, "	",
             l_trab.atdetpdat using "yyyy-mm-dd"," ", l_trab.atdetphor, "	",
             l_trab.atdprvdat, "	",
             ##l_trab.atldat using "yyyy-mm-dd"," ", l_trab.atlhor, "	",
             l_trab.datahoraqtr, "	",
             l_trab.dtahoraqru, "	",
             #l_trab.dstqtd, "	",
             #l_trab.srvlclltt, "	",
             #l_trab.srvlcllgt, "	",
             l_ret.coderro using "<<<<<", "	",
             l_ret.msgerro clipped, "	",
             l_ret.qualificado, "	"
     return l_ret.*
  end if

  # retirado após a inclusao da tolerancia
  # Se QRU > previsao, desqualifica a pontualidade
  # if l_trab.dtahoraqru > l_trab.datahoraqtr then
  #    display "Pontualidade nao qualificada(02): ", "	",
  #            lr_param.atdsrvnum using "<<<<<<<<<", "	",
  #            ##lr_param.atdsrvano using "<<", "	",
  #            l_trab.mdtcod using "<<<<<<", "	",
  #            ##l_trab.ufdcod clipped,"	",
  #            l_trab.cidnom clipped,"	",
  #            #l_trab.orilclltt, "	",
  #            #l_trab.orilcllgt, "	",
  #            l_trab.atdetpdat using "yyyy-mm-dd"," ", l_trab.atdetphor, "	",
  #            l_trab.atdprvdat, "	",
  #            ##l_trab.atldat using "yyyy-mm-dd"," ", l_trab.atlhor, "	",
  #            l_trab.datahoraqtr, "	",
  #            l_trab.dtahoraqru, "	",
  #            #l_trab.dstqtd, "	",
  #            #l_trab.srvlclltt, "	",
  #            #l_trab.srvlcllgt, "	",
  #            l_ret.coderro using "<<<<<", "	",
  #            l_ret.msgerro clipped, "	",
  #            l_ret.qualificado, "	"
  #    return l_ret.*
  # end if

  if l_retcod != 0 or
     l_interv.extprc is null or
     l_interv.toler is null  or
     (l_interv.extprc > l_interv.toler)
     then
     display "Pontualidade nao qualificada(03): "
     display 'Servico:', lr_param.atdsrvnum using "<<<<<<<<<<", "/", lr_param.atdsrvano using "<<"
     display 'Erro: ', l_ret.coderro using "<<<<<", "/", l_ret.msgerro clipped
     display 'l_trab.datahoraqtr: ', l_trab.datahoraqtr
     display 'l_trab.datahoraacn: ', l_trab.datahoraacn
     display 'l_trab.dtahoraqru : ', l_trab.dtahoraqru
     display 'l_trab.datahoraacn: ', l_trab.datahoraacn
     display 'Valores calculados:'
     display 'intervalo acionamento/previsao   (min): ', l_interv.prvitv
     display 'intervalo acionamento/atendimento(min): ', l_interv.atditv
     display 'tempo extra em relacao ao previsto    : ', l_interv.extra
     display 'tempo extra em %                      : ', l_interv.extprc
     display 'tolerancia cadastrada para o criterio.: ', l_interv.toler
     return l_ret.*
  end if

  # todas as condicoes alcançadas, qualifica
  let l_ret.qualificado = "S"
  let l_ret.coderro     = 0

  # identifica quando cumpriu somente pela tolerância
  if l_trab.dtahoraqru > l_trab.datahoraqtr
     then
     let l_msginf = l_msginf clipped, " - Cumpriu pela tolerancia"
  end if

  let l_ret.msgerro = l_msginf clipped

  display "Pontualidade qualificada ", "	",
          lr_param.atdsrvnum using "<<<<<<<<<", "	",
          ##lr_param.atdsrvano using "<<", "	",
          l_trab.mdtcod using "<<<<<<", "	",
          ##l_trab.ufdcod clipped,"	",
          l_trab.cidnom clipped,"	",
          #l_trab.orilclltt, "	",
          #l_trab.orilcllgt, "	",
          l_trab.atdetpdat using "yyyy-mm-dd"," ", l_trab.atdetphor, "	",
          l_trab.atdprvdat, "	",
          ##l_trab.atldat using "yyyy-mm-dd"," ", l_trab.atlhor, "	",
          l_trab.datahoraqtr, "	",
          l_trab.dtahoraqru, "	",
          #l_trab.dstqtd, "	",
          #l_trab.srvlclltt, "	",
          #l_trab.srvlcllgt, "	",
          l_ret.coderro using "<<<<<", "	",
          l_ret.msgerro clipped, "	",
          l_ret.qualificado, "	"

  return l_ret.*

end function

#----------------------------------------------------------------
function ctb00g06_obter_tolerancia(l_prtbnfgrpcod)
#----------------------------------------------------------------

  define l_prtbnfgrpcod integer

  define l_ctb00g06 record
         txtwhe       char(50) ,
         relpamtxt01  char(75) ,
         toler        decimal(5,2)
  end record

  define l_ret record
         coderro     integer ,
         msgerro     char(50)
  end record

  initialize l_ctb00g06.*, l_ret.* to null

  if l_prtbnfgrpcod is null
     then
     return 99, 'Grupo nao identificado', 0
  end if

  let l_ctb00g06.txtwhe[01,04] = '|06|'
  let l_ctb00g06.txtwhe[05,06] = l_prtbnfgrpcod using "&&"
  let l_ctb00g06.txtwhe[07,07] = '|'
  let l_ctb00g06.txtwhe        = ' and relpamtxt matches "*',
                                 l_ctb00g06.txtwhe clipped,'*"'

  call ctd30g00_sel_igbm_whe(1, 'CRTBNFTOLPNT', l_prtbnfgrpcod, 1, l_ctb00g06.txtwhe clipped)
       returning l_ret.coderro, l_ctb00g06.relpamtxt01

  if l_ret.coderro != 0
     then

     let l_ctb00g06.toler = 0  # valor nao cadastrado, nao tem tolerancia

     if l_ret.coderro != 100   # erro na consulta
        then
        display ' Erro na consulta a tolerância: ', l_ret.coderro
     end if
  else
     let l_ctb00g06.toler = l_ctb00g06.relpamtxt01[8,13]
  end if

  if l_ctb00g06.toler is null or l_ctb00g06.toler < 0
     then
     let l_ctb00g06.toler = 0  # valor nulo, nao tem tolerancia
  end if

  return l_ret.coderro, l_ret.msgerro, l_ctb00g06.toler

end function



#----------------------------------------------------------------
function ctb00g06_qualifpontsrr(lr_param)
#----------------------------------------------------------------
  define lr_param       record
         srrcoddig      like datksrr.srrcoddig,  #=> Codigo do Socorrista
         pstcoddig      like dpaksocor.pstcoddig,#=> Codigo do Prestador
         dataini        date,                    #=> Data inicial
         datafim        date                     #=> Data final
  end record

  define lr_ret record
         coderro      integer ,  ## Codigo erro retorno / 0=Ok <>0=Error
         msgerro      char(100), ## Mensagem erro retorno
         qualificado  char(01)   ## Sim ou Nao
  end record

  define lr_trab    record
         atdsrvnum like datmservico.atdsrvnum,
         atdsrvano like datmservico.atdsrvano
  end record

  define lr_retorno     record
          coderro        integer,    #=> Codigo erro / 0=Ok <>0=Error
          msgerro        char(100),  #=> Mensagem erro
          qtdsrv         integer,    #=> Quantidade de servicos
          percpont       dec(8,4)    #=> Percentual de satisfacao
  end record

  define  l_qtdsrvpont integer
  define  l_curr       datetime year to second
  define  l_ret        smallint

  let l_curr = current

  display "[", l_curr, "] INICIO PROCESSAMENTO PONTUALIDADE SOCORRISTA: ", lr_param.srrcoddig
  display "[", l_curr, "] PRESTADOR : ",  lr_param.pstcoddig


  ## Inicializa variaveis
  initialize lr_trab.*, lr_ret.* to null

  let lr_ret.coderro        = 99
  let lr_ret.msgerro        = ""
  let lr_ret.qualificado    = "N"
  let lr_retorno.qtdsrv     = 0
  let lr_retorno.percpont   = 0
  let l_qtdsrvpont          = 0


  if m_prep is null or
     m_prep <> true then
     let l_ret = ctb00g06_prep()
     if l_ret <> 0
        then
        display "Pontualidade erro prepares: ", sqlca.sqlcode
        let lr_retorno.msgerro = "Pontualidade erro ao acessar base de dados: ", sqlca.sqlcode
        let lr_retorno.coderro = sqlca.sqlcode
        return lr_retorno.*
     end if
  end if

  ## Recupera os servicos atendidos por Prestador/Socorrista no periodo apurado
  open cctb00g06004 using lr_param.dataini,
                          lr_param.datafim,
                          lr_param.pstcoddig,
                          lr_param.srrcoddig


  foreach cctb00g06004 into lr_trab.atdsrvnum,
                            lr_trab.atdsrvano

       let lr_retorno.qtdsrv = lr_retorno.qtdsrv + 1

       call ctb00g06_qualifpont(lr_trab.atdsrvnum,
                                lr_trab.atdsrvano,
                                " ")
             returning lr_ret.*

        let l_curr = current

        display "BONIFICACAO | CRITERIO PONTUALIDADE | PRESTADOR: ", lr_param.pstcoddig , " | SOCORRISTA: ", lr_param.srrcoddig , " | SERVICO: ", lr_trab.atdsrvnum , " | MENSAGEM: ", lr_ret.msgerro

        if lr_ret.coderro <> 0 then
           call errorlog(lr_ret.msgerro)
           let l_curr = current
           display "[", l_curr, "] ctb00g06_qualifpontsrr / ", lr_ret.msgerro clipped
        end if

        if lr_ret.qualificado = 'S' then
           let l_qtdsrvpont =  l_qtdsrvpont + 1
        end if

  end foreach

  #identifica a porcentagem de serviços pontuais

  let lr_retorno.percpont = (l_qtdsrvpont / lr_retorno.qtdsrv)*100

  if lr_retorno.percpont is null then
       let lr_retorno.percpont = 0
  end if

  let l_curr = current

  display "[", l_curr, "] FIM PROCESSAMENTO PONTUALIDADE SOCORRISTA: ", lr_param.srrcoddig


  return lr_retorno.*

end function

