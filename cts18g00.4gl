 ############################################################################
 # Nome do Modulo: cts18g00                                        Marcelo  #
 #                                                                 Gilberto #
 # Calcula distancia em Km entre dois pontos (latitude/longitude)  Out/1999 #
 ############################################################################
 #--------------------------------------------------------------------------#
 #                                                                          #
 #                     * * *  ALTERACOES  * * *                             #
 #                                                                          #
 # Data        Autor Fabrica  Data   Alteracao                              #
 # ----------  -------------  ------ -------------------------------------- #
 # 11/05/2004  Cesar Lucca           OSF 35254 / PSI 166421                 #
 #                                   - Substituir o calculo de distancia    #
 #                                     utilizando coord. graus/minutos p/   #
 #                                     graus/decimais.                      #
 #--------------------------------------------------------------------------#

 database porto

#---------------------------------------------------------------------------
 function cts18g00(param)
#---------------------------------------------------------------------------
 define param     record
	lclltt_1  like datkmpalgdsgm.lclltt
       ,lcllgt_1  like datkmpalgdsgm.lcllgt
       ,lclltt_2  like datkmpalgdsgm.lclltt
       ,lcllgt_2  like datkmpalgdsgm.lcllgt
 end record

 define ws        record
	lclltt_1  dec(8,4)
       ,lcllgt_1  dec(8,4)
       ,lclltt_2  dec(8,4)
       ,lcllgt_2  dec(8,4)
       ,dstqtd    dec(16,8)
       ,dstqtd2   dec(8,4)
 end record
 initialize ws.*   to null

 #-- Ponto 1
 #-- Converte latitude e longitude do ponto 1 para res. em km
 let ws.lclltt_1 = param.lclltt_1 * 108
 let ws.lcllgt_1 = param.lcllgt_1 * 108
 #-- Ponto 2
 #-- Converte latitude e longitude do ponto 2 para res. em km
 let ws.lclltt_2 = param.lclltt_2 * 108
 let ws.lcllgt_2 = param.lcllgt_2 * 108

 #--------------------------------------------------------------------------
 #-- Eleva ao quadrado - Funcao pow escrita em "C"
 #--------------------------------------------------------------------------
 let ws.dstqtd = potencia((ws.lclltt_1 - ws.lclltt_2),2) +
		 potencia((ws.lcllgt_1 - ws.lcllgt_2),2)
 #--------------------------------------------------------------------------
 #-- Tira a raiz quadrada - Funcao sqrt escrita em "C"
 #--------------------------------------------------------------------------
 let ws.dstqtd2 = fsqrt(ws.dstqtd)
 return ws.dstqtd2

 end function  ###  cts18g00
#---------------------------------------------------------------------------
#
#---------------------------------------------------------------------------

### #--------------------------------------------------------------------------#
### #                  Formula para Calculo de Distancia                       #
### #--------------------------------------------------------------------------#
### # (x)latitude    (y)longitude  (@)eleva ao quadrado                        #
### # (*)multiplica  (/)divide     (D)Distancia                                #
### #                                                                          #
### #             (raiz quadrada)                                              #
### # D =ascii(92)/------------------------                                    #
### #     ascii(92)((x1 - x2)@ + (y1 - y2)@)                                   #
### #                                                                          #
### # D = ((Distancia * 60) * 30)/1000                                         #
### #                  ---   ---                                               #
### #                   |     |                                                #
### #                   |     |                                                #
### #                   |     +--> Metros                                      #
### #                   +--> Minutos para segundos                             #
### #--------------------------------------------------------------------------#

### #---------------------------------------------------------------------------
###  function cts18g00(param)
### #---------------------------------------------------------------------------
###
###  define param       record
###     lclltt_1        like datkmpalgdsgm.lclltt,
###     lcllgt_1        like datkmpalgdsgm.lcllgt,
###     lclltt_2        like datkmpalgdsgm.lclltt,
###     lcllgt_2        like datkmpalgdsgm.lcllgt
###  end record
###
###  define ws          record
###     lclltt_int      int,
###     lcllgt_int      int,
###     lclltt_dec      dec(6,4),
###     lcllgt_dec      dec(7,5),
###     lclltt_1        dec(8,4),
###     lcllgt_1        dec(8,4),
###     lclltt_2        dec(8,4),
###     lcllgt_2        dec(8,4),
###     dstqtd          dec (16,8),
### #   dstqtd          dec (16,12),
###     dstqtd2         dec (8,4)
###  end record
###
###
###
###
### 	initialize  ws.*  to  null
###
###  initialize ws.*   to null
###
###  # Ponto 1
###
###  let ws.lclltt_int = param.lclltt_1 * (-1)
###  let ws.lcllgt_int = param.lcllgt_1 * (-1)
###
###  let ws.lclltt_dec = ((param.lclltt_1 + ws.lclltt_int)*100) * (-1)
###  let ws.lcllgt_dec = ((param.lcllgt_1 + ws.lcllgt_int)*100) * (-1)
###
###  #Converte latitude e longitude do ponto 1 para MINUTOS
###
###  let ws.lclltt_1 = (ws.lclltt_int * 60) + ws.lclltt_dec
###  let ws.lcllgt_1 = (ws.lcllgt_int * 60) + ws.lcllgt_dec
###
###  # Ponto 2
###
###  let ws.lclltt_int = param.lclltt_2 * (-1)
###  let ws.lcllgt_int = param.lcllgt_2 * (-1)
###
###  let ws.lclltt_dec = ((param.lclltt_2 + ws.lclltt_int)*100) * (-1)
###  let ws.lcllgt_dec = ((param.lcllgt_2 + ws.lcllgt_int)*100) * (-1)
###
###  #Converte latitude e longitude do ponto 2 para MINUTOS
###
###  let ws.lclltt_2 = (ws.lclltt_int * 60) + ws.lclltt_dec
###  let ws.lcllgt_2 = (ws.lcllgt_int * 60) + ws.lcllgt_dec
###
###
###  #--------------------------------------------------------------------------
###  # Eleva ao quadrado - Funcao pow escrita em "C"
###  #--------------------------------------------------------------------------
###  let ws.dstqtd = potencia((ws.lclltt_1 - ws.lclltt_2),2) +
###                  potencia((ws.lcllgt_1 - ws.lcllgt_2),2)
###
###  #--------------------------------------------------------------------------
###  # Tira a raiz quadrada - Funcao sqrt escrita em "C"
###  #--------------------------------------------------------------------------
###  let ws.dstqtd = fsqrt(ws.dstqtd)
###
###  #--------------------------------------------------------------------------
###  # Transforma resultado em Metros->Km
###  #--------------------------------------------------------------------------
###  let ws.dstqtd  = ((ws.dstqtd * 60) * 30) / 1000
###  let ws.dstqtd2 = ws.dstqtd
###
###  return ws.dstqtd2
###
### end function  ###  cts18g00
