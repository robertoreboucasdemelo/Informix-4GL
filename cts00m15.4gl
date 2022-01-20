###############################################################################
# Nome do Modulo: CTS00M15                                           Marcelo  #
#                                                                    Gilberto #
# Retorno ao segurado da previsao de chegada ao local                Set/1996 #
###############################################################################
# ........................................................................... #
#                                                                             #
#                           * * * Alteracoes * * *                            #
#                                                                             #
# Data       Autor Fabrica   Origem     Alteracao                             #
# ---------- --------------  ---------- ------------------------------------- #
# 29/04/2005 Adriano, Meta   PSI189790  obter os servicos multiplos           #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------
 function cts00m15(param)
#---------------------------------------------------------

 define param         record
    atdsrvnum         like datmservico.atdsrvnum  ,
    atdsrvano         like datmservico.atdsrvano
 end record

 define d_cts00m15    record
    dddcod            like datmlcl.dddcod,
    lcltelnum         like datmlcl.lcltelnum,
    retornoflg        char (01),
    nomeret           char (40),
    atdhorpvt         like datmservico.atdhorpvt,
    motivoret         char (40)
 end record



	initialize  d_cts00m15.*  to  null

 open window cts00m15 at 09,15 with form "cts00m15"
                         attribute (form line 1, border)

 options comment line last - 1
 message " (F17)Abandona "

 initialize d_cts00m15.*  to null
 let int_flag = false

 if param.atdsrvnum is null   or
    param.atdsrvano is null   then
    error " Servico nao encontrado. AVISE A INFORMATICA!"
    return
 end if

 select dddcod, lcltelnum
   into d_cts00m15.dddcod, d_cts00m15.lcltelnum
   from datmlcl
  where atdsrvnum  =  param.atdsrvnum
    and atdsrvano  =  param.atdsrvano
    and c24endtip  =  "1"

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na leitura do servico. AVISE A INFORMATICA"
    return
 end if

 display by name d_cts00m15.dddcod
 display by name d_cts00m15.lcltelnum

 input by name d_cts00m15.retornoflg ,
               d_cts00m15.nomeret    ,
               d_cts00m15.atdhorpvt  ,
               d_cts00m15.motivoret    without defaults

   before field retornoflg
      display by name d_cts00m15.retornoflg  attribute (reverse)

   after field retornoflg
      display by name d_cts00m15.retornoflg

      if ((d_cts00m15.retornoflg  is null    or
           d_cts00m15.retornoflg  =  " ")    or
          (d_cts00m15.retornoflg  <>  "S"    and
           d_cts00m15.retornoflg  <>  "N"))  then
         error " Retorno foi informado ? (S)im ou (N)ao"
         next field retornoflg
      end if

      if d_cts00m15.retornoflg  = "N"  then
         next field motivoret
      end if

   before field nomeret
      display by name d_cts00m15.nomeret   attribute (reverse)

   after field nomeret
      display by name d_cts00m15.nomeret

      if fgl_lastkey() = fgl_keyval("up")   or
         fgl_lastkey() = fgl_keyval("left") then
         next field retornoflg
      end if

      if d_cts00m15.nomeret  is null   or
         d_cts00m15.nomeret  = "   "   then
         error " Nome a quem foi dado o retorno deve ser informado!"
         next field nomeret
      end if

   before field atdhorpvt
      display by name d_cts00m15.atdhorpvt   attribute (reverse)

   after field atdhorpvt
      display by name d_cts00m15.atdhorpvt

      if fgl_lastkey() = fgl_keyval("up")     or
         fgl_lastkey() = fgl_keyval("left")   then
         next field nomeret
      end if

      if d_cts00m15.atdhorpvt  is null   or
         d_cts00m15.atdhorpvt  = "   "   then
         error " Previsao de chegada ao local deve ser informada!"
         next field atdhorpvt
      end if
      exit input

   before field motivoret
      display by name d_cts00m15.motivoret attribute (reverse)

   after field motivoret
      display by name d_cts00m15.motivoret

      if fgl_lastkey() = fgl_keyval("up")     or
         fgl_lastkey() = fgl_keyval("left")   then
         next field retornoflg
      end if

      if d_cts00m15.motivoret  is null    or
         d_cts00m15.motivoret  = "  "     then
         error " Motivo pelo qual nao foi dado o retorno deve ser informado!"
         next field motivoret
      end if

   on key (interrupt)
      exit input

 end input

 if not int_flag  then
    call cts00m15_grvhist(param.atdsrvnum      , param.atdsrvano    ,
                          d_cts00m15.retornoflg, d_cts00m15.nomeret ,
                          d_cts00m15.atdhorpvt , d_cts00m15.motivoret)
 end if

 let int_flag = false
 options comment line last
 close window cts00m15

end function  ###  cts00m15

#---------------------------------------------------------------
 function cts00m15_grvhist(param)
#---------------------------------------------------------------

 define param      record
    atdsrvnum      like datmservico.atdsrvnum  ,
    atdsrvano      like datmservico.atdsrvano  ,
    retornoflg     char(01)                    ,
    nomeret        char(40)                    ,
    atdhorpvt      like datmservico.atdhorpvt  ,
    motivoret      char(40)
 end record

 define ws         record
    hora           char(05)                    ,
    historico      like datmservhist.c24srvdsc
 end record

 define l_resultado smallint
 define l_mensagem  char(30)
 define l_cont      smallint

 define al_cts29g00 array[10] of record
    atdmltsrvnum    like datratdmltsrv.atdmltsrvnum
   ,atdmltsrvano    like datratdmltsrv.atdmltsrvano
   ,socntzdes       like datksocntz.socntzdes
   ,espdes          like dbskesp.espdes
   ,atddfttxt       like datmservico.atddfttxt
 end record

 initialize  ws.*  to  null
 initialize  al_cts29g00 to null

 let ws.hora  = current hour to minute

 if param.retornoflg  =  "S"   then
    let ws.historico = "RETORNO ?: SIM ", " P/ ", param.nomeret  clipped,
                       " DE ", param.atdhorpvt
 else
    let ws.historico = "RETORNO ?: NAO ", "MOTIVO: ", param.motivoret
 end if
 begin work
 let l_resultado = cts10g02_historico(param.atdsrvnum, param.atdsrvano, today, ws.hora,
                                      g_issk.funmat, ws.historico, "", "", "", "")
 if l_resultado <> 0 then
    rollback work
    return
 end if
 call cts29g00_obter_multiplo(2 , param.atdsrvnum, param.atdsrvano)
 returning l_resultado
          ,l_mensagem
          ,al_cts29g00[1].*
          ,al_cts29g00[2].*
          ,al_cts29g00[3].*
          ,al_cts29g00[4].*
          ,al_cts29g00[5].*
          ,al_cts29g00[6].*
          ,al_cts29g00[7].*
          ,al_cts29g00[8].*
          ,al_cts29g00[9].*
          ,al_cts29g00[10].*
 if l_resultado = 3 then
    display l_mensagem
    rollback work
    return
 end if
 for l_cont = 1 to 10
    if al_cts29g00[l_cont].atdmltsrvnum is not null then
       let l_resultado = cts10g02_historico(al_cts29g00[l_cont].atdmltsrvnum, al_cts29g00[l_cont].atdmltsrvano,
                                            today, ws.hora, g_issk.funmat, ws.historico, "", "", "", "")
       if l_resultado <> 0 then
          exit for
       end if
    end if
 end for
 if l_resultado <> 0 then
    rollback work
 else
    commit work
 end if
end function  ### cts00m15_grvhist

