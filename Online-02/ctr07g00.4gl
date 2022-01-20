############################################################################
# Nome do Modulo: CTR07G00                                        Marcelo  #
#                                                                 Gilberto #
# Calcula data de referencia (pagto) p/ emissao de relat de O.P.  Dez/1997 #
############################################################################
# Alteracoes:                                                              #
#                                                                          #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                          #
#--------------------------------------------------------------------------#
# 22/04/2002  PSI 15169-6  Wagner       Alteracao data pgto + 4 dias.      #
############################################################################

 database porto

#--------------------------------------------------------------------
 function ctr07g00_data()
#--------------------------------------------------------------------

 define ws    record
    diaqtd    smallint,
    retdat    date,
    utldat    date
 end record

 initialize ws.*  to null

 if time  >= "17:00"   and
    time  <= "23:59"   then
    let ws.diaqtd = 4  ###  Antecipando processamento
 else
    let ws.diaqtd = 3  ###  Processamento normal
 end if

 call dias_uteis(today, 0, "", "S", "S")
      returning ws.utldat

 if ws.utldat  <  today   or
    ws.utldat is  null    then
    display "                      *** ERRO NA VERIFICACAO DA DATA ATUAL! ***"
    exit program(1)
 end if

 if ws.utldat = today  then
 else
    let ws.retdat = today
    display "                      *** NAO HOUVE MOVIMENTO PARA DATA ", ws.retdat, " ***"
    exit program(0)
 end if

 call dias_uteis(today, ws.diaqtd, "", "S", "S")
       returning ws.retdat

 if ws.retdat  <  today   or
    ws.retdat is  null    then
    display "                      *** ERRO NO CALCULO DA DATA PARAMETRO! ***"
    exit program(1)
 end if

 return ws.retdat

end function  ###  ctr07g00_data
