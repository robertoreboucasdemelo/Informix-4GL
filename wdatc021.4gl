#############################################################################
# Nome do Modulo: wdatc021                                           Marcus #
#                                                                           #
# Complementos de servicos enviados pela Porto                     Ago/2001 #
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

 define d_wdatc021_a  record

 atdsrvnum             like datmsrvintcmp.atdsrvnum,
 atdsrvano             like datmsrvintcmp.atdsrvano,
 caddat                like datmsrvintcmp.caddat,
 cadhor                like datmsrvintcmp.cadhor,
 srvcmptxt             like datmsrvintcmp.srvcmptxt
 
 end record

 initialize ws.*          to null
 initialize param.*         to null
 initialize ws2.*         to null  
 initialize d_wdatc021_a to null

 let param.usrtip     = arg_val(1)
 let param.webusrcod  = arg_val(2)
 let param.sesnum     = arg_val(3)
 let param.macsissgl  = arg_val(4)
 let param.atdsrvnum  = arg_val(5)
 let param.atdsrvano  = arg_val(6)
 let param.caddat     = arg_val(7)
 let param.cadhor     = arg_val(8)

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

 #----------------------------------------------
 #  Pesquisa complemento selecionado
 #----------------------------------------------

 select  datmsrvintcmp.atdsrvnum,
        datmsrvintcmp.atdsrvano,
        datmsrvintcmp.caddat,
        datmsrvintcmp.cadhor,
        datmsrvintcmp.srvcmptxt
  into  d_wdatc021_a.atdsrvnum,
        d_wdatc021_a.atdsrvano,
        d_wdatc021_a.caddat,
        d_wdatc021_a.cadhor,
        d_wdatc021_a.srvcmptxt
  from  datmsrvintcmp
  where atdsrvnum = param.atdsrvnum and
        atdsrvano = param.atdsrvano and
        caddat    = param.caddat and
        cadhor    = param.cadhor

 if sqlca.sqlcode <> 0 then

 else
   let ws.servico = param.atdsrvnum using "&&&&&&&", "/", param.atdsrvano using "&&"

   display "PADRAO@@1@@B@@C@@0@@Complemento de informações@@"
   display "PADRAO@@6@@2@@N@@@@0@@1@@29%@@Serviço@@",
                       "@@N@@@@1@@1@@71%@@", ws.servico,
        "@@wdatc016.pl?usrtip=",param.usrtip,"&webusrcod=",
        param.webusrcod clipped,"&sesnum=",param.sesnum clipped,
        "&macsissgl=",param.macsissgl clipped,"&atdsrvnum=",
        param.atdsrvnum clipped,"&atdsrvano=",
        param.atdsrvano clipped,"&caddat=",
        d_wdatc021_a.caddat clipped,
        "&cadhor=",d_wdatc021_a.cadhor clipped, "@@"


   display "PADRAO@@8@@Data@@",d_wdatc021_a.caddat,"@@"
   display "PADRAO@@8@@Hora@@",d_wdatc021_a.cadhor,"@@"
   display "PADRAO@@8@@Observação@@",d_wdatc021_a.srvcmptxt,"@@"
 end if

#   call wdatc021_espera(d_wdatc021_a.caddat,d_wdatc021_a.cadhor)
#              returning ws.espera

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

#--------------------------------------------------------------------------
 function wdatc021_espera(param)
#--------------------------------------------------------------------------

 define param       record
    data            date,
    hora            datetime hour to minute
 end record

 define hora        record
    atual           datetime hour to second,
    h24             datetime hour to second,
    espera          char (09)
 end record


 initialize hora.*  to null
 let hora.atual = time

 if param.data  =  today  then
    let hora.espera = hora.atual - param.hora
 else
    let hora.h24    = "23:59:59"
    let hora.espera = hora.h24 - param.hora
    let hora.h24    = "00:00:00"
    let hora.espera = hora.espera + (hora.atual - hora.h24) + "00:00:01"
 end if

 return hora.espera

 end function   ###
