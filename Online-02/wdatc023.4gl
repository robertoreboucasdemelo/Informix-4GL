#############################################################################
# Nome do Modulo: wdatc023                                           Marcus #
#                                                                           #
# Atualiza a data/hora que o usuario (Prestador) acessou complemento.       #
#                                                                  Ago/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#############################################################################

database porto

main

 define ws record
    pstcoddig        like dpaksocor.pstcoddig,
    time             char (08),
    horaatu          datetime hour to second ,
    data             datetime year to day ,
    linha            char (700),
    tempod           dec  (3,0),
    sttsess          dec  (1,0),
    comando          char (500),
    atdetpcod        dec  (1,0),
    servico          char (13),
    atdsrvorg        like datmservico.atdsrvorg,
    srvtipabvdes     like datksrvtip.srvtipabvdes,
    espera           char (06)
 end record

 define param       record
    usrtip          char (1),
    webusrcod       char (06),
    sesnum          char (10),
    macsissgl       char (10),
    atdsrvnum       like datmsrvint.atdsrvnum,
    atdsrvano       like datmsrvint.atdsrvano,
    caddat          like datmsrvint.caddat,
    cadhor          like datmsrvint.cadhor

 end record

 define ws2         record
   statusprc        dec  (1,0),
   sestblvardes1    char (256),
   sestblvardes2    char (256),
   sestblvardes3    char (256),
   sestblvardes4    char (256),
   sespcsprcnom     char (256),
   prgsgl           char (256),
   acsnivcod        dec  (1,0),
   webprscod        dec  (16,0)
 end record

 initialize ws.*          to null
 initialize param.*       to null
 initialize ws2.*         to null  

 let param.usrtip     = arg_val(1)
 let param.webusrcod  = arg_val(2)
 let param.sesnum     = arg_val(3)
 let param.macsissgl  = arg_val(4)
 let param.atdsrvnum  = arg_val(5)
 let param.atdsrvano = arg_val(6)
 let param.caddat    = arg_val(7)
 let param.cadhor    = arg_val(8)

 let ws.horaatu    = time
 let ws.data       = current

 #------------------------------------------
 #  ABRE BANCO   (TESTE ou PRODUCAO)
 #------------------------------------------
 call fun_dba_abre_banco("CT24HS")
 set isolation to dirty read

 #---------------------------------------------
 #  CHECA STATUS DA SESSAO E RECEBE PARAMETROS
 #---------------------------------------------

call wdatc002(param.usrtip,
              param.webusrcod,
              param.sesnum,
              param.macsissgl)
    returning ws2.*
 

  if ws2.statusprc <> 0 then
    display "NOSESS@@Por quest\365es de seguran\347a seu tempo de<BR> permanência nesta p\341gina atingiu o limite m\341ximo.@@"
     exit program(0)
  end if            

   update datmsrvintcmp
   set atldat = current,
       atlhor = current,
       atlemp = "0",
       atlusrtip = param.usrtip,
       atlmat = param.webusrcod,
       atldat = current,
       atlhor = current
where  atdsrvnum = param.atdsrvnum and
       atdsrvano = param.atdsrvano and
       caddat = param.caddat and
       cadhor = param.cadhor     

 #------------------------------------
 # ATUALIZA TEMPO DE SESSAO DO USUARIO
 #------------------------------------

 call wdatc003(param.usrtip,
               param.webusrcod,
               param.sesnum,
               param.macsissgl,
               ws2.*)
     returning ws.sttsess

end main
