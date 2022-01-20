 ##############################################################################
 # Nome do Modulo: cts00m33                                          Marcus   #
 #                                                                            #
 # Calcula distancia entre pontos do servico                         Fev/2002 #
 ##############################################################################
 # Alteracoes:                                                                #
 #                                                                            #
 # DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                            #
 #----------------------------------------------------------------------------#
 # 20/03/2012  Ivan, BRQ PSI-2011-22603  Projeto alteracao cadastro de destino#
 ##############################################################################

 database porto

#------------------------------------------------------------
 function cts00m33(param)
#------------------------------------------------------------

 define param         record
    origem            dec (3,0),
    lclltt_1          like datkmpalgdsgm.lclltt,
    lcllgt_1          like datkmpalgdsgm.lcllgt,
    lclltt_2          like datkmpalgdsgm.lclltt,
    lcllgt_2          like datkmpalgdsgm.lcllgt
 end record

 define l_tempo      decimal(6,1),
        l_rota_final char(01)

 define a_cts00m33    record
    dstqtd            dec (8,4)
 end record

 define arr_aux       smallint
 define confirma      char(1),
        l_tipo_rota   char(07),
        l_status      smallint


        let     arr_aux  =  null
        let     confirma  =  null
        let     l_status  =  null

        initialize  a_cts00m33.*  to  null

  if param.lclltt_1 is null then
    call cts08g01("A","N","",
                  "","Servico sem coordenadas da ocorrencia","")
                  returning confirma
    return
 else
    if param.lclltt_2 is null then
       call cts08g01("A","N","",
                  "","Servico sem coordenadas do destino","")
                  returning confirma
       return
    end if
 end if

 open window w_cts00m33 at  11,09 with form "cts00m33"
         attribute(form line first, border, message line last - 1)

 initialize a_cts00m33.*        to null

 let l_tempo      = null
 let l_rota_final = null

 # -> BUSCA O TIPO DE ROTA
 let l_tipo_rota = null
 let l_tipo_rota = ctx25g05_tipo_rota()

  # -> VERIFICA SE A ROTERIZACAO ESTA ATIVA
  if ctx25g05_rota_ativa() then
     call ctx25g02(param.lclltt_1,
                   param.lcllgt_1,
                   param.lclltt_2,
                   param.lcllgt_2,
                   l_tipo_rota,
                   0)

          returning a_cts00m33.dstqtd,
                    l_tempo,
                    l_rota_final
  else
     call cts18g00(param.lclltt_1,
                   param.lcllgt_1,
                   param.lclltt_2,
                   param.lcllgt_2)

          returning a_cts00m33.dstqtd
  end if

    display by name a_cts00m33.dstqtd

    call cts00m33_cria_temp()
       returning l_status

    if l_status = 0 then
       call cts00m33_grava_distancia(a_cts00m33.dstqtd)
    end if

    message " (F17)Abandona"
    input by name confirma without defaults
       after field confirma
       next field confirma

       on key (interrupt, control-c)
          exit input
    end input


 let int_flag = false
 close window  w_cts00m33

end function   ### cts00m33

#--------------------------------------------------------------------------#
 function cts00m33_cria_temp()
#--------------------------------------------------------------------------#

  whenever error continue
  drop table tmp_distancia
  whenever error stop
  if sqlca.sqlcode = 0    or
     sqlca.sqlcode = -206 then

     whenever error continue
     create temp table tmp_distancia(dstqtd decimal(8,4)) with no log
     whenever error stop

     if sqlca.sqlcode <> 0 then
        error "Erro temporaria calculo distancia:", sqlca.sqlcode," - Create cts00m33_cria_temp :"
              , sqlca.sqlerrd[2]," MSG: ",sqlca.sqlerrm clipped sleep 2
        error "Nao sera gravado a distancia entre pontos no historico" sleep 2
        return 1
     end if

  else
     whenever error continue
     delete from tmp_distancia
     whenever error stop
  end if

  return 0

end function

#--------------------------------------------------------------------------#
 function cts00m33_grava_distancia(l_dstqtd)
#--------------------------------------------------------------------------#
  define l_dstqtd  decimal(8,4)

  whenever error continue
  insert into tmp_distancia (dstqtd)
       values (l_dstqtd)
  whenever error stop

  if sqlca.sqlcode <> 0 then
     error "Erro insert calculo distancia:", sqlca.sqlcode," - INSERT cts00m33_grava_distancia :"
           , sqlca.sqlerrd[2]," MSG: ",sqlca.sqlerrm clipped sleep 2
     error "Nao sera gravado a distancia entre pontos no historico" sleep 2
  end if

end function

#--------------------------------#
 function cts00m33_calckm(param)
#--------------------------------#

     define param record
         flag char(01),
         lclltt_1  like datkmpalgdsgm.lclltt,
         lcllgt_1  like datkmpalgdsgm.lcllgt,
         lclltt_2  like datkmpalgdsgm.lclltt,
         lcllgt_2  like datkmpalgdsgm.lcllgt,
         kmlimite  decimal (8,4)
     end record

     define l_resultado  smallint,
            l_mensagem   char(50),
            l_tipo_rota  char(07),
            l_dstqtd     decimal(8,4),
            l_km1        decimal(5,0),
            l_km2        decimal(5,0),
            l_dif        decimal(5,0),
            l_tempo      decimal(6,1),
            l_rota_final char(01),
            l_confirma   char(01),
            l_msg        char(40),
            l_msg2       char(40),
            l_status     smallint

     let l_status = null

     if ctx25g05_rota_ativa() then
        let  l_tipo_rota = ctx25g05_tipo_rota()
        call ctx25g02(param.lclltt_1,
                      param.lcllgt_1,
                      param.lclltt_2,
                      param.lcllgt_2,
                      l_tipo_rota,
                      0)

             returning l_dstqtd,
                       l_tempo,
                       l_rota_final
     else
        call cts18g00(param.lclltt_1,
                      param.lcllgt_1,
                      param.lclltt_2,
                      param.lcllgt_2)

             returning l_dstqtd
     end if

     call cts00m33_cria_temp()
        returning l_status

     if l_status = 0 then
        call cts00m33_grava_distancia(l_dstqtd)
     end if

     if  l_dstqtd > param.kmlimite then
         let l_km1 = l_dstqtd
         let l_km2 = param.kmlimite
         let l_dif = l_km1 - l_km2
         let l_msg = "Limite = ",l_km2 using "<<<<&",
                     " Calculado = ",l_km1 using "<<<<#"
         let l_msg2= " Diferenca Aproximada = ",l_dif  using "<<<<#"

         if param.flag is null then
            call cts08g01("A","N","LIMITE DE KM EXCEDIDO. O VALOR DEVERA" ,
                          " SER NEGOCIADO COM O PRESTADOR.",
                          l_msg, l_msg2)
                 returning l_confirma
         else
            call cts08g01("A","N","","",
                          l_msg,"")
                 returning l_confirma
         end if

     end if

 end function

