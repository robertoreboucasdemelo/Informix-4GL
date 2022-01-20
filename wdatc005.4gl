#############################################################################
# Nome do Modulo: wdatc005                                           Marcus #
#                                                                      Raji #
# Posicionamento de frota                                          Jan/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
database porto

main
 define wdatc005  record
    atdvclsgl     like datkveiculo.atdvclsgl,
    c24atvcod     like dattfrotalocal.c24atvcod,
    data          char (10),
    hora          datetime hour to minute,
    tempo         char (06),
    brrnom        like datmfrtpos.brrnom
 end record

 define ws record
    pstcoddig        like dpaksocor.pstcoddig,
    usrtip           char (1),
    webusrcod        char (06),
    sesnum           dec  (10,0),
    macsissgl        char (10),
    tempo            char (08),
    horaatu          datetime hour to minute,
    linha            char (1000),
    tempod           dec  (3,0),
    sttsess          dec  (1,0)
 end record

 define ws1         record
    usrtip          char (1),
    webusrcod       char (06),
    sesnum          dec  (10,0),
    macsissgl       char (10),
    inicio          char (11)
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

 initialize ws.*         to null
 initialize ws1.*        to null
 initialize ws2.*        to null
 initialize wdatc005.*   to null

 let ws1.usrtip     = arg_val(1)
 let ws1.webusrcod  = arg_val(2)
 let ws1.sesnum     = arg_val(3)
 let ws1.macsissgl  = arg_val(4)
 let ws1.inicio     = arg_val(5)

 let ws.tempo       = time
 let ws.horaatu    = ws.tempo[1,5]

 #------------------------------------------
 #  ABRE BANCO   (TESTE ou PRODUCAO)
 #------------------------------------------
 call fun_dba_abre_banco("CT24HS")
 set isolation to dirty read

 #---------------------------------------------
 #  CHECA STATUS DA SESSAO E RECEBE PARAMETROS
 #---------------------------------------------

 call wdatc002(ws1.usrtip,
               ws1.webusrcod,
               ws1.sesnum,
               ws1.macsissgl)
      returning ws2.*

   if ws2.statusprc <> 0 then
      display "NOSESS@@Por quesascii(92)5es de seguraascii(92)7a seu tempo de<BR> permaascii(92)2ncia nesta ascii(92)1gina atingiu o limite ascii(92)1ximo.@@"
      exit program(0)
   end if

 let ws.pstcoddig = ws2.webprscod

 #------------------------------------------------------------------
 # Prepara pesquisa por codigo do prestador
 #------------------------------------------------------------------
 declare c_wdatc005 cursor with hold for
    select datkveiculo.atdvclsgl,
           dattfrotalocal.c24atvcod,
           dattfrotalocal.cttdat,
           dattfrotalocal.ctthor,
           datmfrtpos.brrnom
      from datkveiculo, dattfrotalocal, datmfrtpos
     where datkveiculo.pstcoddig    = ws.pstcoddig
       and datkveiculo.socctrposflg = 'S'
       and datkveiculo.socoprsitcod = '1'
       and datkveiculo.socacsflg    = '0'
       and dattfrotalocal.socvclcod = datkveiculo.socvclcod
       and datmfrtpos.socvclcod = datkveiculo.socvclcod
       and datmfrtpos.socvcllcltip = 1
     order by #  atdvclpriflg   desc,
              #  c24atvcod[3,3] desc,
              cttdat         asc ,
              ctthor         asc ,
              atdvclsgl      asc

 display 'PRESTADOR@@', ws.pstcoddig using "<<<<<<<<&", '@@'
 
 display "PADRAO@@6@@5@@B@@C@@0@@2@@20%@@Veículo@@@@B@@C@@0@@2@@20%@@Situação@@@@B@@C@@0@@2@@20%@@Horário@@@@B@@C@@0@@2@@20%@@Tempo@@@@B@@C@@0@@2@@20%@@Local@@@@"

 foreach c_wdatc005 into  wdatc005.atdvclsgl,
                          wdatc005.c24atvcod,
                          wdatc005.data,
                          wdatc005.hora,
                          wdatc005.brrnom

    #------------------------------------------------------------------
    # Calcula tempo de espera
    #------------------------------------------------------------------
    let ws.tempod = 000
    initialize  wdatc005.tempo   to null

    if wdatc005.c24atvcod  is not null   and
       wdatc005.c24atvcod  <>  "QTP"     then
       call wdatc005_calcula(wdatc005.hora,
                              wdatc005.data,
                              ws.horaatu)
            returning  wdatc005.tempo, ws.tempod
    end if

    let ws.linha = "PADRAO@@6@@5@@N@@C@@1@@1@@20%@@",wdatc005.atdvclsgl,
           "@@wdatc006.pl?usrtip=",ws1.usrtip,"&webusrcod=",
           ws1.webusrcod clipped,"&sesnum=",ws1.sesnum clipped

    let ws.linha = ws.linha clipped, "&voltar=1" clipped, "&inicio=",ws1.inicio clipped,
           "&macsissgl=",ws1.macsissgl clipped,"&atdvclsgl=",
           wdatc005.atdvclsgl clipped

    let ws.linha = ws.linha clipped, "&acao=1@@N@@C@@1@@1@@20%@@",
           wdatc005.c24atvcod,"@@@@N@@C@@1@@1@@20%@@",wdatc005.hora,
           "@@@@N@@C@@1@@1@@20%@@",wdatc005.tempo,
           "@@@@N@@C@@1@@1@@20%@@",wdatc005.brrnom,"@@@@"

    display ws.linha clipped

end foreach

 #------------------------------------
 # ATUALIZA TEMPO DE SESSAO DO USUARIO
 #------------------------------------

  call wdatc003(ws1.usrtip,
                ws1.webusrcod,
                ws1.sesnum,
                ws1.macsissgl,
                ws2.*)
       returning ws.sttsess
end main

#---------------------------------------------------------------------
 function wdatc005_calcula(par3)   ## Calcula tempo na atividade
#---------------------------------------------------------------------

 define  par3    record
    hora         datetime hour to minute,
    data         char(10),
    horaatu      datetime hour to minute
 end record

 define  ws_h24     datetime hour to minute
 define  ret_tempo  char(06)
 define  ret_tempod dec(3,0)



#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize	ws_h24  to  null
	initialize	ret_tempo  to  null
	initialize	ret_tempod  to  null

 if par3.data  is not null  and
    par3.data    <=  today   then
    if par3.data  =  today   then
       let ret_tempo  =  par3.horaatu - par3.hora
       let ret_tempod =  ret_tempo[1,3]  using  "&&&"
    else
       let ws_h24     =  "23:59"
       let ret_tempo  =  ws_h24 - par3.hora
       let ws_h24     =  "00:00"
       let ret_tempo  =  ret_tempo + (par3.horaatu - ws_h24) + "00:01"
       let ret_tempod =  ret_tempo[1,3]  using  "&&&"
    end if
 end if

 return ret_tempo, ret_tempod

end function  ###-- wdatc005_calcula
