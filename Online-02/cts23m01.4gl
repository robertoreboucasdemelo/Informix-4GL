#############################################################################
# Nome do Modulo: CTS23M01                                                  #
#                                                                   Marcus  #
# Inconsistencias da frota (tempos dos MDT's )                      Out/00  #
#---------------------------------------------------------------------------#
# 19/01/2001  PSI 12339-0   Marcus 	Incluir link com Posicao da Frota   #
#############################################################################

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------------------------
function cts23m01( )
#------------------------------------------------------------------------------

 define a_cts23m01	array[300] of record
   mdtcod		like datkveiculo.mdtcod,
   atdvclsgl            like datkveiculo.atdvclsgl,
   srrabvnom            like datksrr.srrabvnom,
   atldat               like datmfrtpos.atldat,
   atlhor               like datmfrtpos.atlhor,
   tempo		char(9),
   mdtctrcod   		like datkmdt.mdtctrcod
 end record

 define b_cts23m01      array[300] of record
   mdtcod               like datkveiculo.mdtcod,
   atdvclsgl            like datkveiculo.atdvclsgl,
   srrabvnom            like datksrr.srrabvnom,
   atldat               like datmfrtpos.atldat,
   atlhor               like datmfrtpos.atlhor,
   tempo                char(9),
   mdtctrcod            like datkmdt.mdtctrcod
 end record

 define ws	 record
   c24atvcod     like dattfrotalocal.c24atvcod,
   socvclcod	 like dattfrotalocal.socvclcod,
   srrcoddig     like dattfrotalocal.srrcoddig,
   total         smallint,
   c24atvpesq    char(3),
   hora          char(9),
   horaatual     datetime hour to second,
   horadif       datetime hour to second,
   horaint       datetime hour to second,
   comando       char (600),
   cabec         char (70),
   cabec1        char (70),
   atdprscod     like datmservico.atdprscod,
   atdvclsgl     like datkveiculo.atdvclsgl,
   flag_cts00m03 dec  (01,0)
 end record

 define tot_ctr1 smallint
 define tot_ctr2 smallint
 define tot_ctr3 smallint
 define tot_ctr4 smallint
 define tot_inc  smallint
 define arr_aux  smallint
 define arr_aux1 smallint
 define arr_aux2 smallint
 define arr_aux3 smallint
 define scr_aux  smallint

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
                  " and dattfrotalocal.c24atvcod = ? ",
                  " and datmfrtpos.lclltt is not null ",
                  " and datmfrtpos.lcllgt is not null ",
                  " and datkveiculo.mdtcod is not null ",
                  " and datmfrtpos.socvclcod= dattfrotalocal.socvclcod ",
                  " and datkveiculo.socvclcod= dattfrotalocal.socvclcod"

  prepare p_cts23m01_001 from ws.comando
  declare c_cts23m01_001 cursor for p_cts23m01_001

 let ws.comando = "select dattfrotalocal.socvclcod, ",
                  "       dattfrotalocal.c24atvcod, ",
                  "       datmfrtpos.atlhor,",
                  "       datmfrtpos.atldat,",
                  "       dattfrotalocal.srrcoddig ",
                  " from dattfrotalocal,datmfrtpos,datkveiculo ",
                  "  where datmfrtpos.atldat < TODAY ",
                  " and datmfrtpos.socvcllcltip = 1 ",
                  " and dattfrotalocal.c24atvcod = ? ",
                  " and datmfrtpos.lclltt is not null ",
                  " and datmfrtpos.lcllgt is not null ",
                  " and datkveiculo.mdtcod is not null ",
                  " and datmfrtpos.socvclcod= dattfrotalocal.socvclcod ",
                  " and datkveiculo.socvclcod= dattfrotalocal.socvclcod"

  prepare p_cts23m01_002 from ws.comando
  declare c_cts23m01_002 cursor for p_cts23m01_002

 let ws.comando = "select datkveiculo.mdtcod, ",
                  "       datkveiculo.atdvclsgl, ",
                  "       datkmdt.mdtctrcod ",
                  " from datkveiculo, datkmdt ",
                  " where datkveiculo.socvclcod = ? ",
                  " and datkveiculo.mdtcod = datkmdt.mdtcod"

  prepare p_cts23m01_003 from ws.comando
  declare c_cts23m01_003 cursor for p_cts23m01_003

  let ws.comando = "select srrabvnom ",
                   " from datksrr ",
                   " where srrcoddig = ? "

  prepare p_cts23m01_004 from ws.comando
  declare c_cts23m01_004 cursor for p_cts23m01_004

#---------------------------------------------------------------------------
# Inicializa variaveis
#---------------------------------------------------------------------------

 initialize a_cts23m01	 to null
 initialize b_cts23m01   to null
 initialize ws.*         to null
 let tot_inc = 0
 let arr_aux = 1

 let tot_ctr1 = 0
 let tot_ctr2 = 0
 let tot_ctr3 = 0
 let tot_ctr4 = 0

#---------------------------------------------------------------------------

 OPEN WINDOW wnd1 AT 4,2 WITH FORM "cts23m01"
             attribute(form line first , comment line last -1)
 display " " to cabec

 while true

 initialize a_cts23m01   to null
 initialize b_cts23m01   to null
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

 input by name ws.c24atvpesq

 	before field c24atvpesq
           display ws.c24atvpesq to c24atvpesq  attribute (reverse)

        after field c24atvpesq
           if ws.c24atvpesq is not null then
		if ws.c24atvpesq <> "QRV" and
                   ws.c24atvpesq <> "QRX" and
		   ws.c24atvpesq <> "QRU" and
		   ws.c24atvpesq <> "REC" and
                   ws.c24atvpesq <> "INI" and
                   ws.c24atvpesq <> "FIM" then
                      error "Codigo de atividade nao permitida!"
                      next field c24atvpesq
                 end if
           end if

           select count(*) into ws.total
           from dattfrotalocal,datmfrtpos,datkveiculo
           where datmfrtpos.socvcllcltip = 1
           and dattfrotalocal.c24atvcod = ws.c24atvpesq
           and datmfrtpos.lclltt is not null
           and datmfrtpos.lcllgt is not null
           and datkveiculo.mdtcod is not null
           and datmfrtpos.socvclcod= dattfrotalocal.socvclcod
           and datkveiculo.socvclcod= dattfrotalocal.socvclcod

           let ws.cabec = "Total ", ws.c24atvpesq , " : ",
                          ws.total using "&&&"
           display ws.cabec to cabec

        on key (interrupt)
         exit input

 end input

 if int_flag   then
      exit while
 end if

 open c_cts23m01_001 using ws.hora, ws.c24atvpesq

 foreach c_cts23m01_001 into ws.socvclcod,
                           ws.c24atvcod,
                           b_cts23m01[arr_aux].atlhor,
                           b_cts23m01[arr_aux].atldat,
                           ws.srrcoddig

     call cts23m01_espera(b_cts23m01[arr_aux].atldat,b_cts23m01[arr_aux].atlhor)
 	returning b_cts23m01[arr_aux].tempo

    open c_cts23m01_003 using ws.socvclcod
    fetch c_cts23m01_003 into b_cts23m01[arr_aux].mdtcod,
                         b_cts23m01[arr_aux].atdvclsgl,
                         b_cts23m01[arr_aux].mdtctrcod

    open c_cts23m01_004 using ws.srrcoddig
    fetch c_cts23m01_004 into b_cts23m01[arr_aux].srrabvnom

    case b_cts23m01[arr_aux].mdtctrcod
       when 1
	  let tot_ctr1 = tot_ctr1 + 1
       when 2
	  let tot_ctr2 = tot_ctr2 + 1
	when 3
	  let tot_ctr3 = tot_ctr3 + 1
        when 4
          let tot_ctr4 = tot_ctr4 + 1
    end case

    let tot_inc = tot_inc + 1
    let arr_aux = arr_aux + 1

 end foreach

 open c_cts23m01_002 using  ws.c24atvpesq

 foreach c_cts23m01_002 into ws.socvclcod,
                           ws.c24atvcod,
                           b_cts23m01[arr_aux].atlhor,
                           b_cts23m01[arr_aux].atldat,
                           ws.srrcoddig

     call cts23m01_espera(b_cts23m01[arr_aux].atldat,b_cts23m01[arr_aux].atlhor)
        returning b_cts23m01[arr_aux].tempo

    open c_cts23m01_003 using ws.socvclcod
    fetch c_cts23m01_003 into b_cts23m01[arr_aux].mdtcod,
                         b_cts23m01[arr_aux].atdvclsgl,
                         b_cts23m01[arr_aux].mdtctrcod

    open c_cts23m01_004 using ws.srrcoddig
    fetch c_cts23m01_004 into b_cts23m01[arr_aux].srrabvnom

    case b_cts23m01[arr_aux].mdtctrcod
       when 1
          let tot_ctr1 = tot_ctr1 + 1
       when 2
          let tot_ctr2 = tot_ctr2 + 1
        when 3
          let tot_ctr3 = tot_ctr3 + 1
        when 4
          let tot_ctr4 = tot_ctr4 + 1
    end case

    let tot_inc = tot_inc + 1
    let arr_aux = arr_aux + 1

 end foreach

      #---------------------------------------------------------------
      # Classifica o array por ordem crescente de distancia
      #---------------------------------------------------------------
      for arr_aux2 = 1 to arr_aux - 1
        for arr_aux1 = 1 to arr_aux - 1
          if b_cts23m01[arr_aux1].tempo  is not null   then
             if b_cts23m01[arr_aux1].tempo > a_cts23m01[arr_aux2].tempo  or
                a_cts23m01[arr_aux2].tempo  is null                        then
                let a_cts23m01[arr_aux2].*  =  b_cts23m01[arr_aux1].*
                let arr_aux3  =  arr_aux1
             end if
          end if
                end for
                initialize b_cts23m01[arr_aux3]  to null
      end for


 let ws.cabec = "Total ", ws.c24atvpesq , " : ",
                          ws.total using "&&&", " Inconsistentes : ",
                          tot_inc using "&&&"
           display ws.cabec to cabec

 let ws.cabec1 = "Controladoras 1 : ", tot_ctr1 using "&&&",
                          " - 2 : ", tot_ctr2 using "&&&",
                          " - 3 : ", tot_ctr3 using "&&&",
                          " - 4 : ", tot_ctr4 using "&&&"
           display ws.cabec1 to cabec1

 if arr_aux > 1 then
  message " (F17)Abandona, (F8)Frota, (F9)Sinais "
         call set_count(arr_aux-1)

         options insert key F40,
                 delete key F45

    input array a_cts23m01 without defaults  from  s_cts23m01.*

            before row
               let arr_aux = arr_curr()
               let scr_aux = scr_line()

               display a_cts23m01[arr_aux].*  to
                       s_cts23m01[scr_aux].*  attribute(reverse)

            after row
               display a_cts23m01[arr_aux].*  to
                       s_cts23m01[scr_aux].*

            before field mdtcod
               display a_cts23m01[arr_aux].mdtcod  to
                    s_cts23m01[scr_aux].mdtcod  attribute (reverse)

            after  field mdtcod
               display a_cts23m01[arr_aux].mdtcod  to
                    s_cts23m01[scr_aux].mdtcod

               if fgl_lastkey() = fgl_keyval("down")    or
               fgl_lastkey() = fgl_keyval("right")   or
               fgl_lastkey() = fgl_keyval("return")  then
               if arr_aux   <  300                          and
                  a_cts23m01[arr_aux+1].mdtcod  is null   then
                  error " Nao existem mais linhas nesta direcao!"
                  next field mdtcod
               end if
            end if

          #---------------------------------------------------------------
          # Abre Posicao da Frota com a viatura selecionada
          #---------------------------------------------------------------
          on key (F8)
             let arr_aux = arr_curr()
             call cts00m03(2,2,"","",a_cts23m01[arr_aux].atdvclsgl,"","","")
                                returning ws.atdprscod,
                                          ws.atdvclsgl,
                                          ws.srrcoddig,
                                          ws.socvclcod,
                                          ws.flag_cts00m03

          #---------------------------------------------------------------
          # Consulta mensagens recebidas dos MDTs
          #---------------------------------------------------------------
          on key (F9)
             let arr_aux = arr_curr()
             call ctn44c00(2, a_cts23m01[arr_aux].atdvclsgl, "")

         on key (interrupt)
                clear form
                exit input

     end input

  else
    message ""
    ERROR "Nao exitem viaturas"
  end if

  let int_flag = false

end while

 let int_flag = false
 close window  wnd1

end function

#--------------------------------------------------------------------------
 function cts23m01_espera(param)
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

 end function   ###--- cts23m01_espera
