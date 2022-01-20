#############################################################################
# Nome do Modulo: wdatc013                                                  #
#                                                                   Marcus  #
# Inconsistencias da frota (tempos dos MDT's )                      Out/01  #
#############################################################################

 database porto

#------------------------------------------------------------------------------
main
#------------------------------------------------------------------------------

 define param       record
    usrtip          char (1),
    webusrcod       char (06),
    sesnum          char (10),
    macsissgl       char (10),
    inicio          char (11)
 end record

 define a_wdatc013 	array[300] of record
   mdtfqcnum            like datkmdtctr.mdtfqcnum,
   mdtcod		like datkveiculo.mdtcod,
   c24atvcod            like dattfrotalocal.c24atvcod, 
   atdvclsgl            like datkveiculo.atdvclsgl,
   srrabvnom            like datksrr.srrabvnom,
   atldat               like datmfrtpos.atldat,
   atlhor               like datmfrtpos.atlhor,
   tempo		char(9),
   mdtctrcod   		like datkmdt.mdtctrcod
 end record

 define b_wdatc013      array[300] of record
   mdtfqcnum            like datkmdtctr.mdtfqcnum,
   mdtcod               like datkveiculo.mdtcod,
   c24atvcod            like dattfrotalocal.c24atvcod,
   atdvclsgl            like datkveiculo.atdvclsgl,
   srrabvnom            like datksrr.srrabvnom,
   atldat               like datmfrtpos.atldat,
   atlhor               like datmfrtpos.atlhor,
   tempo                char(9),
   mdtctrcod            like datkmdt.mdtctrcod
 end record

 define ws	 record
   socvclcod	 like dattfrotalocal.socvclcod,
   srrcoddig     like dattfrotalocal.srrcoddig,
   total         smallint,
   c24atvpesq    char(3),
   hora          char(9),
   data          char(10),
   horaatual     datetime hour to second,
   horadif       datetime hour to second,
   horaint       datetime hour to second,
   comando       char (600),
   cabec         char (70),
   cabec1        char (70),
   atdprscod     like datmservico.atdprscod,
   atdvclsgl     like datkveiculo.atdvclsgl,
   sttsess       dec  (1,0),
   linha         char (1000)
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


 define tot_ctr1 smallint
 define tot_ctr2 smallint
 define tot_ctr3 smallint
 define tot_ctr4 smallint

 define tot_QRA smallint
 define tot_QRV smallint
 define tot_QRX smallint
 define tot_QRU smallint
 define tot_REC smallint
 define tot_INI smallint
 define tot_FIM smallint 

 define tot_inc  smallint
 define arr_aux  smallint
 define arr_aux1 smallint
 define arr_aux2 smallint
 define arr_aux3 smallint
 define scr_aux  smallint

 initialize param.* to null
 initialize a_wdatc013 to null
 initialize b_wdatc013 to null
 initialize ws.* to null
 initialize ws2.* to null

 initialize tot_ctr1 to null
 initialize tot_ctr2 to null
 initialize tot_ctr3 to null
 initialize tot_ctr4 to null

 initialize tot_QRA to null
 initialize tot_QRV to null
 initialize tot_QRX to null
 initialize tot_QRU to null
 initialize tot_REC to null
 initialize tot_INI to null
 initialize tot_FIM to null 

 initialize tot_inc  to null
 initialize arr_aux  to null
 initialize arr_aux1 to null
 initialize arr_aux2 to null
 initialize arr_aux3 to null
 initialize scr_aux  to null

 let param.usrtip     = arg_val(1)
 let param.webusrcod  = arg_val(2)
 let param.sesnum     = arg_val(3)
 let param.macsissgl  = arg_val(4)
 let param.inicio     = arg_val(5)

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
      display "NOSESS@@Por quest\365es de seguran\347a seu tempo de<BR> permanêncianesta página atingiu seu limite máximo.@@"
      exit program(0)
   end if

#------------------------------------------------------------------------------
# Preparacao das Consultas
#------------------------------------------------------------------------------

 let ws.comando = "select dattfrotalocal.socvclcod, ",
                  "       dattfrotalocal.c24atvcod, ",
                  "       datmfrtpos.atlhor,",
                  "       datmfrtpos.atldat,",
                  "       dattfrotalocal.srrcoddig ",
                  " from dattfrotalocal,datmfrtpos,datkveiculo ",
                  " where datmfrtpos.atlhor < ? ",
                  "   and datmfrtpos.atldat = TODAY ",
                  " and datmfrtpos.socvcllcltip = 1 ",
                  " and dattfrotalocal.c24atvcod <> 'QTP' ",
                  " and datmfrtpos.lclltt is not null ",
                  " and datmfrtpos.lcllgt is not null ",
                  " and datkveiculo.mdtcod is not null ",
                  " and datkveiculo.pstcoddig = ? ",
                  " and datmfrtpos.socvclcod= dattfrotalocal.socvclcod ",
                  " and datkveiculo.socvclcod= dattfrotalocal.socvclcod"

  prepare s_datmfrtpos from ws.comando
  declare c_datmfrtpos cursor for s_datmfrtpos

 let ws.comando = "select dattfrotalocal.socvclcod, ",
                  "       dattfrotalocal.c24atvcod, ",
                  "       datmfrtpos.atlhor,",
                  "       datmfrtpos.atldat,",
                  "       dattfrotalocal.srrcoddig ",
                  " from dattfrotalocal,datmfrtpos,datkveiculo ",
                  "  where datmfrtpos.atldat < TODAY ",
                  " and datmfrtpos.socvcllcltip = 1 ",
                  " and dattfrotalocal.c24atvcod <> 'QTP' ",
                  " and datkveiculo.pstcoddig = ? ",
                  " and datmfrtpos.lclltt is not null ",
                  " and datmfrtpos.lcllgt is not null ",
                  " and datkveiculo.mdtcod is not null ",
                  " and datmfrtpos.socvclcod= dattfrotalocal.socvclcod ",
                  " and datkveiculo.socvclcod= dattfrotalocal.socvclcod"

  prepare s_datmfrtpos_ant from ws.comando
  declare c_datmfrtpos_ant cursor for s_datmfrtpos_ant

 let ws.comando = "select datkveiculo.mdtcod, ",
                  "       datkveiculo.atdvclsgl, ",
                  "       datkmdt.mdtctrcod ",
                  " from datkveiculo, datkmdt ",
                  " where datkveiculo.socvclcod = ? ",
                  " and datkveiculo.mdtcod = datkmdt.mdtcod"

  prepare s_datkmdt from ws.comando
  declare c_datkmdt cursor for s_datkmdt

  let ws.comando = "select srrabvnom ",
                   " from datksrr ",
                   " where srrcoddig = ? "

  prepare s_datksrr from ws.comando
  declare c_datksrr cursor for s_datksrr

  let ws.comando = "select mdtfqcnum from datkmdt, datkmdtctr ",
                   " where mdtcod = ? ",
                   " and datkmdt.mdtctrcod = datkmdtctr.mdtctrcod"

  prepare s_datkmdtctr from ws.comando
  declare c_datkmdtctr cursor for s_datkmdtctr

#---------------------------------------------------------------------------
# Inicializa variaveis
#---------------------------------------------------------------------------

 initialize a_wdatc013 	 to null
 initialize b_wdatc013   to null
 initialize ws.*         to null
 let tot_inc = 0
 let arr_aux = 1

 let tot_ctr1 = 0
 let tot_ctr2 = 0
 let tot_ctr3 = 0
 let tot_ctr4 = 0

#---------------------------------------------------------------------------

 initialize a_wdatc013   to null
 initialize b_wdatc013   to null
 initialize ws.*         to null
 let tot_inc = 0
 let arr_aux = 1
 let tot_ctr1 = 0
 let tot_ctr2 = 0
 let tot_ctr3 = 0


 let ws.horaatual = time
 let ws.horadif   = "00:21:00"
 let ws.horaint   = "00:01:00"
 let ws.hora      = ws.horaatual - ws.horadif
 let ws.horaatual = ws.hora
 let ws.hora = ws.hora[1,6]
 let ws.data = today

#          select count(*) into ws.total
#          from dattfrotalocal,datmfrtpos,datkveiculo
#          where datmfrtpos.socvcllcltip = 1
#          and dattfrotalocal.c24atvcod = ws.c24atvpesq
#          and datmfrtpos.lclltt is not null
#          and datmfrtpos.lcllgt is not null
#          and datkveiculo.mdtcod is not null
#          and datmfrtpos.socvclcod= dattfrotalocal.socvclcod
#          and datkveiculo.socvclcod= dattfrotalocal.socvclcod

#          let ws.cabec = "Total ", ws.c24atvpesq , " : ",
#                         ws.total using "&&&"
#          display ws.cabec to cabec


#open c_datmfrtpos using ws.hora, ws.c24atvpesq
 open c_datmfrtpos using ws.hora, ws2.webprscod

 foreach c_datmfrtpos into ws.socvclcod,
                           b_wdatc013[arr_aux].c24atvcod,
                           b_wdatc013[arr_aux].atlhor,
                           b_wdatc013[arr_aux].atldat,
                           ws.srrcoddig
     call wdatc013_espera(b_wdatc013[arr_aux].atldat,b_wdatc013[arr_aux].atlhor)
 	returning b_wdatc013[arr_aux].tempo

    open c_datkmdt using ws.socvclcod
    fetch c_datkmdt into b_wdatc013[arr_aux].mdtcod,
                         b_wdatc013[arr_aux].atdvclsgl,
                         b_wdatc013[arr_aux].mdtctrcod

    open c_datksrr using ws.srrcoddig
    fetch c_datksrr into b_wdatc013[arr_aux].srrabvnom

    open c_datkmdtctr using b_wdatc013[arr_aux].mdtcod
    fetch c_datkmdtctr into b_wdatc013[arr_aux].mdtfqcnum

    case b_wdatc013[arr_aux].c24atvcod
       when 'QRA'
            let tot_QRA = tot_QRA + 1
       when 'QRV'
            let tot_QRV = tot_QRV + 1  
       when 'QRX'
            let tot_QRX = tot_QRX + 1
       when 'QRU'
            let tot_QRU = tot_QRU + 1
       when 'REC'
            let tot_REC = tot_REC + 1
       when 'INI'
            let tot_INI = tot_INI + 1
       when 'FIM' 
            let tot_FIM = tot_FIM + 1
    end case

#   case b_wdatc013[arr_aux].mdtctrcod
#      when 1
#  let tot_ctr1 = tot_ctr1 + 1
#      when 2
#  let tot_ctr2 = tot_ctr2 + 1
#when 3
#  let tot_ctr3 = tot_ctr3 + 1
#       when 4
#         let tot_ctr4 = tot_ctr4 + 1
#   end case

    let tot_inc = tot_inc + 1
    let arr_aux = arr_aux + 1

 end foreach

#open c_datmfrtpos_ant using  ws.c24atvpesq
 open c_datmfrtpos_ant using ws2.webprscod
 

 foreach c_datmfrtpos_ant into ws.socvclcod,
                           b_wdatc013[arr_aux].c24atvcod,
                           b_wdatc013[arr_aux].atlhor,
                           b_wdatc013[arr_aux].atldat,
                           ws.srrcoddig

     call wdatc013_espera(b_wdatc013[arr_aux].atldat,b_wdatc013[arr_aux].atlhor)
        returning b_wdatc013[arr_aux].tempo

    open c_datkmdt using ws.socvclcod
    fetch c_datkmdt into b_wdatc013[arr_aux].mdtcod,
                         b_wdatc013[arr_aux].atdvclsgl,
                         b_wdatc013[arr_aux].mdtctrcod

    open c_datkmdtctr using b_wdatc013[arr_aux].mdtcod
    fetch c_datkmdtctr into b_wdatc013[arr_aux].mdtfqcnum

    open c_datksrr using ws.srrcoddig
    fetch c_datksrr into b_wdatc013[arr_aux].srrabvnom

    case b_wdatc013[arr_aux].c24atvcod
       when 'QRA'
            let tot_QRA = tot_QRA + 1
       when 'QRV'
            let tot_QRV = tot_QRV + 1
       when 'QRX'
            let tot_QRX = tot_QRX + 1
       when 'QRU'
            let tot_QRU = tot_QRU + 1
       when 'REC'
            let tot_REC = tot_REC + 1
       when 'INI'
            let tot_INI = tot_INI + 1
       when 'FIM'
            let tot_FIM = tot_FIM + 1
    end case

#   case b_wdatc013[arr_aux].mdtctrcod
#      when 1
#         let tot_ctr1 = tot_ctr1 + 1
#      when 2
#         let tot_ctr2 = tot_ctr2 + 1
#       when 3
#         let tot_ctr3 = tot_ctr3 + 1
#       when 4
#         let tot_ctr4 = tot_ctr4 + 1
#   end case

    let tot_inc = tot_inc + 1
    let arr_aux = arr_aux + 1

 end foreach
 
 display "PADRAO@@1@@B@@C@@0@@Total de viaturas inconsistentes@@"

 display "PADRAO@@6@@7@@B@@C@@0@@2@@14%@@QRA@@@@B@@C@@0@@2@@14%@@QRV@@@@B@@C@@0@@2@@14%@@QRX@@@@B@@C@@0@@2@@14%@@QRU@@@@B@@C@@0@@2@@14%@@REC@@@@B@@C@@0@@2@@14%@@INI@@@@B@@C@@0@@2@@15%@@FIM@@@@"

 display "PADRAO@@6@@7@@B@@C@@1@@1@@14%@@",tot_QRA,
         "@@@@B@@C@@1@@1@@14%@@",tot_QRV,
         "@@@@B@@C@@1@@1@@14%@@",tot_QRX,
         "@@@@B@@C@@1@@1@@14%@@",tot_QRU,
         "@@@@B@@C@@1@@1@@14%@@",tot_REC,
         "@@@@B@@C@@1@@1@@14%@@",tot_INI,
         "@@@@B@@C@@1@@1@@15%@@",tot_FIM,"@@@@"

display "PADRAO@@1@@B@@C@@3@@@@"

 if arr_aux > 1 then

    display "PADRAO@@6@@7@@B@@C@@0@@2@@10%@@Viatura@@@@B@@C@@0@@2@@10%@@Situação@@@@B@@C@@0@@2@@18%@@Socorrista@@@@B@@C@@0@@2@@10%@@Data@@@@B@@C@@0@@2@@10%@@Hora@@@@B@@C@@0@@2@@10%@@Tempo@@@@B@@C@@0@@2@@12%@@Frequência@@@@"

    #---------------------------------------------------------------
    # Classifica o array por ordem crescente de distancia
    #---------------------------------------------------------------
    for arr_aux2 = 1 to arr_aux - 1
      for arr_aux1 = 1 to arr_aux - 1
        if b_wdatc013[arr_aux1].tempo  is not null   then
           if b_wdatc013[arr_aux1].tempo > a_wdatc013[arr_aux2].tempo  or
              a_wdatc013[arr_aux2].tempo  is null                        then
              let a_wdatc013[arr_aux2].*  =  b_wdatc013[arr_aux1].*
              let arr_aux3  =  arr_aux1
           end if
        end if
              end for
              initialize b_wdatc013[arr_aux3]  to null
    end for

    for arr_aux2 = 1 to arr_aux - 1
#tempo
#mdtctrcod
          
          let ws.linha = "PADRAO@@6@@7@@N@@C@@1@@1@@10%@@",a_wdatc013[arr_aux2].atdvclsgl,
                         "@@wdatc006.pl?usrtip=",param.usrtip,"&webusrcod=",
                         param.webusrcod clipped,"&sesnum=",param.sesnum clipped,
                         "&macsissgl=",param.macsissgl clipped, "&voltar=1" clipped,
                         "&inicio=", param.inicio clipped
          
          let ws.linha = ws.linha clipped, "&atdvclsgl=",
                         a_wdatc013[arr_aux2].atdvclsgl clipped,
                         "&acao=0@@N@@C@@1@@1@@10%@@",
                         a_wdatc013[arr_aux2].c24atvcod,"@@@@N@@C@@1@@1@@18%@@",
                         a_wdatc013[arr_aux2].srrabvnom
          
          let ws.linha = ws.linha clipped, "@@@@N@@C@@1@@1@@10%@@",a_wdatc013[arr_aux2].atldat,
                         "@@@@N@@C@@1@@1@@10%@@",a_wdatc013[arr_aux2].atlhor,
                         "@@@@N@@C@@1@@1@@10%@@",a_wdatc013[arr_aux2].tempo,
                         "@@@@N@@C@@1@@1@@12%@@",a_wdatc013[arr_aux2].mdtfqcnum,"@@@@"
           
          display ws.linha

    end for
 else
    display "PADRAO@@1@@N@@C@@1@@Nenhuma viatura inconsistente@@"
 end if 

 #------------------------------------
 # ATUALIZA TEMPO DE SESSAO DO USUARIO
 #------------------------------------

  call wdatc003(param.usrtip,
                param.webusrcod,
                param.sesnum,
                param.macsissgl
                ,ws2.*)
       returning ws.sttsess

end main

#--------------------------------------------------------------------------
 function wdatc013_espera(param)
#--------------------------------------------------------------------------

 define param       record
    atldat          like datmmdtlog.atldat,
    atlhor          like datmmdtlog.atlhor
 end record

 define hora        record
    atual           datetime hour to second,
    h24             datetime hour to second,
    espera          char (09)
 end record


 initialize hora.*  to null
 let hora.atual = time

 if param.atldat = today  then
    let hora.espera = hora.atual - param.atlhor
 else
    let hora.h24    = "23:59:59"
    let hora.espera = hora.h24 - param.atlhor
    let hora.h24    = "00:00:00"
    let hora.espera = hora.espera + (hora.atual - hora.h24) + "00:00:01"
 end if

 return hora.espera

 end function   ###--- wdatc013_espera
