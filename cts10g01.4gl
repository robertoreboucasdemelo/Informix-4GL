#############################################################################
# Nome do Modulo: CTS10G01                                         Marcelo  #
#                                                                  Gilberto #
# Funcoes genericas para envio de fax                              Mar/1998 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 04/03/1999  PSI 7913-8   Wagner       Alteracao inclui situacao 1 tambem  #
#                                       para faxsubcod = "VD" codigo Vidros #
#---------------------------------------------------------------------------#
# 15/12/1999               Gilberto     Inclusao de rotinas de tratamento   #
#                                       de erro e codigo de erro no retorno #
#---------------------------------------------------------------------------#
# 09/11/2001  PSI 125969   Raji         Alteracao inclui situacao 1 tambem  #
#                                       para faxsubcod = "RS" codigo Reserva#
#############################################################################

 database porto


#-----------------------------------------------------------------------
 function cts10g01_trx_fax(param)
#-----------------------------------------------------------------------

 define param        record
    atdsrvnum        like datmservico.atdsrvnum ,
    atdsrvano        like datmservico.atdsrvano ,
    tipo             dec  (1,0),    #--> 1-Envio, 2-Reenvio
    faxsubcod        like datmfax.faxsubcod
 end record

 define ws           record
    faxenvsit        like datmfax.faxenvsit     ,
    faxch1           like gfxmfax.faxch1        ,
    faxch2           like gfxmfax.faxch2        ,
    faxchx           char (10)                  ,
    count            smallint                   ,
    erroflg          char (01)
 end record




	initialize  ws.*  to  null

 initialize ws.*  to null

 let ws.erroflg  = "N"
 let ws.count   =  0

 if param.atdsrvnum is null   or
    param.atdsrvano is null   then
    error " Servico nao informado (cts10g01_trxfax). AVISE INFORMATICA!"
    return ws.erroflg
 end if

 let ws.faxchx = param.atdsrvnum  using "&&&&&&&&",
                 param.atdsrvano  using "&&"

 let ws.faxch1 = ws.faxchx

 if param.tipo  =  1   then
    select count(*)
      into ws.count
      from datmfax
     where datmfax.faxsiscod = "CT"
       and datmfax.faxsubcod = param.faxsubcod
       and datmfax.faxch1    = ws.faxch1
       and datmfax.faxenvsit in (1,3)

     if ws.count  >  0   then
        error " Ja' existe transmissao pendente para este servico!"
        let ws.erroflg  =  "S"
     end if
 end if

 if param.tipo  =  2   then
    select count(*)
      into ws.count
      from datmfax
     where datmfax.faxsiscod = "CT"
       and datmfax.faxsubcod = param.faxsubcod
       and datmfax.faxch1    = ws.faxch1

     if ws.count  >  2   then
        error " Reenvio de fax deve ser realizado apenas 2 vezes!"
        let ws.erroflg  =  "S"
     end if
 end if

 return ws.erroflg

end function   ###--  cts10g01_trx_fax


#-----------------------------------------------------------------------
 function cts10g01_sit_fax(param)
#-----------------------------------------------------------------------

 define param        record
    faxenvsit        like datmfax.faxenvsit ,
    faxsubcod        like datmfax.faxsubcod ,
    faxch1           like datmfax.faxch1    ,
    faxch2           like datmfax.faxch2
 end record




 update datmfax  set  faxenvsit  =  param.faxenvsit
  where faxsiscod = "CT"
    and faxsubcod = param.faxsubcod
    and faxch1    = param.faxch1
    and faxch2    = param.faxch2

 if sqlca.sqlcode <> 0   then
    error "Erro (", sqlca.sqlcode, ") no cancelamento do envio!"
 end if

end function   ###--  cts10g01_sit_fax


#-----------------------------------------------------------------------
 function cts10g01_enviofax(param)
#-----------------------------------------------------------------------

 define param        record
    atdsrvnum        like datmservico.atdsrvnum ,
    atdsrvano        like datmservico.atdsrvano ,
    lignum           like datmligacao.lignum    ,
    faxsubcod        like datmfax.faxsubcod     ,
    funmat           like isskfunc.funmat
 end record

 define ws           record
    faxenvsit        like datmfax.faxenvsit     ,
    faxch1           like gfxmfax.faxch1        ,
    faxch2           like gfxmfax.faxch2        ,
    faxchx           char (10)                  ,
    envflg           dec(1,0)
 end record



	initialize  ws.*  to  null

 initialize ws.*  to null

 let ws.envflg = false

 if param.faxsubcod = "PS"  or
    param.faxsubcod = "VD"  or
    param.faxsubcod = "OF"  or
    param.faxsubcod = "RS"  then
    let ws.faxenvsit = 1
 end if

 if param.atdsrvnum is not null  and
    param.atdsrvano is not null  then
    let ws.faxchx = param.atdsrvnum  using "&&&&&&&&",
                    param.atdsrvano  using "&&"
 else
    if param.lignum is not null  then
       let ws.faxchx = param.lignum  using "&&&&&&&&&&"
    else
       error " Parametros nao informados! AVISE A INFORMATICA!"
       return ws.envflg, ws.faxch1, ws.faxch2
    end if
 end if

 let ws.faxch1 = ws.faxchx

 whenever error continue

 select max(faxch2)
   into ws.faxch2
   from datmfax
  where datmfax.faxsiscod = "CT"             and
        datmfax.faxsubcod = param.faxsubcod  and
        datmfax.faxch1    = ws.faxch1

 if sqlca.sqlcode < 0  then
    return ws.envflg, ws.faxch1, ws.faxch2
 end if

 if ws.faxch2  is null   then
    let ws.faxch2 = 0
 end if
 let ws.faxch2 = ws.faxch2 + 1

 insert into datmfax ( faxsiscod, faxsubcod,
                       faxch1   , faxch2   ,
                       faxenvdat, faxenvhor,
                       funmat   , faxenvsit )
             values  ( "CT"     , param.faxsubcod ,
                       ws.faxch1, ws.faxch2, today,
                       current hour to second,
                       param.funmat, ws.faxenvsit)

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na gravacao do envio do fax !"
 else
    let ws.envflg = true
    error " *** FAX SENDO TRANSMITIDO, PROSSIGA ***"
 end if

 whenever error stop

 return ws.envflg, ws.faxch1, ws.faxch2

end function   ###--  cts10g01_enviofax
