############################################################################
# Nome de Modulo: ctb00g00                                        Gilberto #
#                                                                 Marcelo  #
# Funcao p/ verificacao de pagamento para servicos cancelados     Jun/1998 #
############################################################################
# Alteracoes:                                                              #
#                                                                          #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                          #
#--------------------------------------------------------------------------#
# 28/09/1998  PSI 14064-3  Wagner       Pagto QRU cancelada em ate 10'min. #
#                                       valido somante para que tem MDT.   #
#..........................................................................#
# 22/08/2005  PSI 194573 Cristiane Silva  Alteração do tempo de 30 para    #
#                                         20 minutos.                      #
############################################################################


#---------------------------------------------------------------------------
# Retorno: (1) Com pagamento - "Cancel. apos 30 minutos"
#          (2) Sem pagamento - "Cancel. antes de 30 minutos"
#          (3) Sem pagamento - "Cancel. nao realizado pelo atendente"
#          (4) Com pagamento - "Cancel. apos 10 minutos"     (SOMENTE C/MDT)
#          (5) Sem pagamento - "Cancel. antes de 10 minutos" (SOMENTE C/MDT)
#---------------------------------------------------------------------------

#PSI 194573
#---------------------------------------------------------------------------
# Retorno: (1) Com pagamento - "Cancel. apos 20 minutos"
#          (2) Sem pagamento - "Cancel. antes de 20 minutos"
#          (3) Sem pagamento - "Cancel. nao realizado pelo atendente"
#          (4) Com pagamento - "Cancel. apos 10 minutos"     (SOMENTE C/MDT)
#          (5) Sem pagamento - "Cancel. antes de 10 minutos" (SOMENTE C/MDT)
#---------------------------------------------------------------------------


 database porto

#-----------------------------------------------------------------
 function ctb00g00(param)
#-----------------------------------------------------------------

 define param      record
    atdsrvnum      like datmservico.atdsrvnum,
    atdsrvano      like datmservico.atdsrvano,
    cnldat         like datmservico.cnldat,
    atdfnlhor      like datmservico.atdfnlhor
 end record

 define ws         record
    ligdat         like datmligacao.ligdat,
    lighorinc      like datmligacao.lighorinc,
    difcnlcan      char (06),
    difcnlcan2     datetime hour to minute,
    horaatu        datetime hour to minute,
    h24            datetime hour to minute,
    canpgtcod      dec (1,0),
    mdtstt         like datkmdt.mdtstt,
    atddat         like datmservico.atddat
 end record



        initialize  ws.*  to  null

 initialize ws.*   to null
 let ws.canpgtcod  =  3

 #----------------------------------------------------------------------
 # Busca cancelamento do servico feito pelo atendente
 #----------------------------------------------------------------------
 #declare c_ctb00g00_001  cursor for
 #   select ligdat, lighorinc
 #     from datmligacao
 #    where atdsrvnum  =  param.atdsrvnum
 #      and atdsrvano  =  param.atdsrvano
 #      and c24astcod  =  "CAN"
 #
 #foreach c_ctb00g00_001  into  ws.ligdat,
 #                             ws.lighorinc
 #   exit foreach
 #end foreach

 declare c_ctb00g00_001 cursor for
 select atdetpdat, atdetphor
   from datmsrvacp
 where atdsrvnum = param.atdsrvnum
   and atdsrvano = param.atdsrvano
   and atdetpcod > 4
   order by 1 desc, 2 desc

 open c_ctb00g00_001
 fetch c_ctb00g00_001 into ws.ligdat, ws.lighorinc
 close c_ctb00g00_001

 #-------------------------------------------------------------------
 # Verifica diferenca entre a conclusao e o cancelamento do servico
 #-------------------------------------------------------------------
 if ws.ligdat  is not null   then

    if ws.ligdat  =  param.cnldat   then
       let ws.difcnlcan = ws.lighorinc - param.atdfnlhor
    else
      let ws.h24        =  "23:59"
      let ws.difcnlcan  =  ws.h24 - param.atdfnlhor
      let ws.h24        =  "00:00"
      let ws.difcnlcan  =
          ws.difcnlcan + (ws.lighorinc - ws.h24) + "00:01"
    end if

    let ws.difcnlcan2  =  ws.difcnlcan

    #----------------------------
    # Verifica se socorro tem MDT
    #----------------------------
    select datmservico.atddat, datkmdt.mdtstt
      into ws.atddat, ws.mdtstt
      from datmservico, datkveiculo, datkmdt
     where datmservico.atdsrvnum = param.atdsrvnum
       and datmservico.atdsrvano = param.atdsrvano
       and datkveiculo.socvclcod = datmservico.socvclcod
       and datkmdt.mdtcod        = datkveiculo.mdtcod

    # INICIO DO PROCESSO PARA PAGAMENTO ATE 10MIN.
    if ws.atddat <= "22/10/2001" then
       let ws.mdtstt = 1
    end if

    if ws.mdtstt is not null  and
       ws.mdtstt = 0          then
       # TEM MDT
       let ws.canpgtcod  =  5
       if ws.difcnlcan2  >  "00:05"   then
          let ws.canpgtcod  =  4
       end if
    else
       # NAO TEM MDT
       let ws.canpgtcod  =  2
#       if ws.difcnlcan2  >  "00:30"   then
       if ws.difcnlcan2  >  "00:20"   then #PSI 194573
          let ws.canpgtcod  =  1
       end if
    end if

 end if

 return ws.canpgtcod, ws.difcnlcan2

 end function   ##-- ctb00g00
