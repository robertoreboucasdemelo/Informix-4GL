###############################################################################
# Nome do Modulo: ctx03g00                                           Marcelo  #
#                                                                    Gilberto #
# Verifica existencia de acionamento - Just In Time                  Jun/1998 #
###############################################################################
# 02/07/2004 - Mariana(FSW)   - CT 222810
#                               Selecionar atdsrvorg da tabela datmservico
###############################################################################

# ...........................................................................#
#                                                                            #
#                           * * * Alteracoes * * *                           #
#                                                                            #
# Data       Autor Fabrica    Origem    Alteracao                            #
# ---------- --------------   --------- -------------------------------------#
# 30/01/2006 T.Solda, Meta    PSI194387 Passar o "vcompila" no modulo        #
#----------------------------------------------------------------------------#

database porto

#------------------------------------------------------------------
 function ctx03g00(param)
#------------------------------------------------------------------

 define param        record
    ramcod           like datrligapol.ramcod,
    succod           like datrligapol.succod,
    aplnumdig        like datrligapol.aplnumdig,
    itmnumdig        like datrligapol.itmnumdig,
    orrdat           date
 end record

 define ws           record
    ligdat           like datmligacao.ligdat,
    c24astcod        like datmligacao.c24astcod,
    inidat           date,
    fimdat           date,
    sqlcode          integer,
    jitflg           char (01),
    atdsrvnum        like datmligacao.atdsrvnum,
    atdsrvano        like datmligacao.atdsrvano,
    atdetpcod        like datmsrvacp.atdetpcod
 end record

define  l_atdsrvorg  like datmservico.atdsrvorg


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	let	l_atdsrvorg  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#


	initialize  ws.*  to  null

 initialize ws.*  to null

 let ws.jitflg  =  "N"
 let ws.inidat  =  param.orrdat - 5 units day
 let ws.fimdat  =  param.orrdat + 5 units day

#---------------------------------------------------------------------
# Nao verifica erros / Leitura "suja"
#---------------------------------------------------------------------
 set isolation to dirty read
 whenever error continue

 declare c_ctx03g00_001  cursor for
    select datmligacao.ligdat,
           datmligacao.c24astcod,
           datmligacao.atdsrvnum,
           datmligacao.atdsrvano,
           datmservico.atdsrvorg
      from datrligapol, datmligacao, datmservico
     where datrligapol.succod     =  param.succod
       and datrligapol.ramcod     =  param.ramcod
       and datrligapol.aplnumdig  =  param.aplnumdig
       and datrligapol.itmnumdig  =  param.itmnumdig
       and datrligapol.lignum     =  datmligacao.lignum
       and datmservico.atdsrvnum  =  datmligacao.atdsrvnum
       and datmservico.atdsrvano  =  datmligacao.atdsrvano

 foreach c_ctx03g00_001  into  ws.ligdat,
                           ws.c24astcod,
                           ws.atdsrvnum,
                           ws.atdsrvano,
                           l_atdsrvorg

    if l_atdsrvorg = 15              then
       if ws.ligdat  >=  ws.inidat   and
          ws.ligdat  <=  ws.fimdat   then

         select datmsrvacp.atdetpcod
                into ws.atdetpcod
           from datmsrvacp
          where atdsrvnum = ws.atdsrvnum
            and atdsrvano = ws.atdsrvano
            and atdsrvseq = (select max(atdsrvseq)
                               from datmsrvacp
                              where atdsrvnum = ws.atdsrvnum
                                and atdsrvano = ws.atdsrvano)

         if ws.atdetpcod = 4 or ws.atdetpcod = 11 then
            let ws.jitflg  =  "S"
            exit foreach
         end if
       end if
    end if
 end foreach

 let ws.sqlcode = sqlca.sqlcode

#---------------------------------------------------------------------
# Volta a verificar erros / Leitura "normal"
#---------------------------------------------------------------------
 whenever error stop
 set isolation to committed read

 return ws.sqlcode, ws.jitflg

end function  ###  ctx03g00
