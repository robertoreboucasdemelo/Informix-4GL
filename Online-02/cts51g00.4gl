#----------------------------------------------------------------  #
# PORTO SEGURO CIA DE SEGUROS GERAIS                               #
#................................................................  #
#  Sistema        :                                                #
#  Modulo         : CTS51G00.4gl                                   #
#                   Verificador de disponibilidade geral           #
#  Analista Resp. : Raji                                           #
#  PSI            :                                                #
#................................................................  #
#  Desenvolvimento: Andre Oliveira                                 #
#  Liberacao      :                                                #
#................................................................  #
#                                                                  #
#                  * * * Alteracoes * * *                          #
#                                                                  #
# Data       Autor Fabrica  Origem    Alteracao                    #
# ---------- -------------- --------- ---------------------------  #
# 02/03/2010 Adriano Santos PSI252891 Inclusao do padrao idx 4 e 5 #
#..................................................................#
database porto


#------ Funcao para disponibilidade em cidades com GPS-----#
function cts51g00_cidade_com_GPS(lr_param,
    lr_documento,
    lr_servicos,
    l_acesso_web,
    l_criou_tabela,
    aux_hora,
    aux_today,
    d_socntzcod,
    c_local)
   define l_criou_tabela smallint
   define l_acesso_web smallint
   define aux_today char(10),
      aux_hora char(5)
   define d_socntzcod like datmsrvre.socntzcod
   define c_local record
    lclltt like datmlcl.lclltt,
        lgdnom like datmlcl.lgdnom,
        lgdnum like datmlcl.lgdnum,
        brrnom like datmlcl.brrnom,
        cidnom like datmlcl.cidnom,
        ufdcod like datmlcl.ufdcod,
        lgdcep like datmlcl.lgdcep
   end record
   define lr_param      record
          lclltt        like datmlcl.lclltt,
          lcllgt        like datmlcl.lcllgt,
          mpacidcod     like datkmpacid.mpacidcod,
          atdsrvorg     like datmservico.atdsrvorg,
          socntzcod     like datmsrvre.socntzcod,
          espcod        like datmsrvre.espcod,
          data          like datmservico.atddatprg,
          hora          like datmservico.atdhorprg,
          atmacnprtcod  like datkatmacnprt.atmacnprtcod,
          acnlmttmp     like datkatmacnprt.acnlmttmp,
          c24lclpdrcod  like datmlcl.c24lclpdrcod
   end record
   define lr_servicos  record          #---> Array de servicos
        socntzcod   like datmsrvre.socntzcod,
        espcod      like datmsrvre.espcod,
        socntzcod_1 like datmsrvre.socntzcod,
        espcod_1    like datmsrvre.espcod,
        socntzcod_2 like datmsrvre.socntzcod,
        espcod_2    like datmsrvre.espcod,
        socntzcod_3 like datmsrvre.socntzcod,
        espcod_3    like datmsrvre.espcod,
        socntzcod_4 like datmsrvre.socntzcod,
        espcod_4    like datmsrvre.espcod,
        socntzcod_5 like datmsrvre.socntzcod,
        espcod_5    like datmsrvre.espcod,
        socntzcod_6 like datmsrvre.socntzcod,
        espcod_6    like datmsrvre.espcod,
        socntzcod_7 like datmsrvre.socntzcod,
        espcod_7    like datmsrvre.espcod,
        socntzcod_8 like datmsrvre.socntzcod,
        espcod_8    like datmsrvre.espcod,
        socntzcod_9 like datmsrvre.socntzcod,
        espcod_9    like datmsrvre.espcod,
        socntzcod_10 like datmsrvre.socntzcod,
        espcod_10    like datmsrvre.espcod
   end record
   define lr_documento record   #----> Parametro de entrada do documento
        atdsrvnum like datmservico.atdsrvnum,   #   usado pelo sistema de laudo.
        atdsrvano like datmservico.atdsrvano,
    ramcod   like datrservapol.ramcod,
    succod    like datrligapol.succod,
    aplnumdig like datrligapol.aplnumdig,
    itmnumdig like datrligapol.itmnumdig,
    c24astcod like datkassunto.c24astcod,
    ciaempcod like datmligacao.ciaempcod
   end record

   define l_atmacnflg like datkassunto.atmacnflg
   define l_tem_cota      smallint
   define l_tem_outros_srv char(1)
   define lr_ret           record
          pergunta         char(1),
          veiculo_aciona   like datkveiculo.socvclcod,
          cota_disponivel  smallint
   end record

   define l_erro_log   char(80)

   initialize lr_ret.* to null
   let lr_ret.pergunta = "N"
   let l_atmacnflg = null
   let l_tem_cota = null
   let l_tem_outros_srv =''
   if lr_param.lclltt  is null   or
      lr_param.lcllgt  is null   or
      (lr_param.c24lclpdrcod <> 3 and
       lr_param.c24lclpdrcod <> 4 and # PSI 252891
       lr_param.c24lclpdrcod <> 5 and
       (not cts40g12_gpsacncid(c_local.cidnom, c_local.ufdcod)) # Verifica se o acionamento GPS pode ser realizado pela coordenada da Cidade
       )then
      call ctc59m03_quota_imediato(lr_param.mpacidcod, lr_param.atdsrvorg,
                                   lr_param.socntzcod, aux_today,
                                   aux_hora)
            returning lr_ret.cota_disponivel

      if lr_ret.cota_disponivel = true then
         let lr_ret.pergunta = "S"
      end if
      ## Verifica se existe outros serviços para decidir a reserva da cota
      call cts51g00_ver_existencia_outros_srv(lr_documento.atdsrvnum,
                                              lr_documento.atdsrvano,
                                              lr_documento.ramcod,
                                              lr_documento.succod,
                                              lr_documento.aplnumdig,
                                              lr_documento.itmnumdig,
                                              lr_param.data,
                                              aux_today,
                                              d_socntzcod,
                                              c_local.lclltt,
              c_local.lgdnom,
              c_local.lgdnum,
              c_local.brrnom,
              c_local.cidnom,
              c_local.ufdcod,
              c_local.lgdcep,
           "")
           returning l_tem_outros_srv

      ## achou outro servico
      if l_tem_outros_srv = "N" then
         let lr_ret.cota_disponivel = true
      end if

      return lr_ret.*

   end if
   #--- Este if testa se o chamado da funcao veio do portal ou do cts17m00----#
   if l_acesso_web <> true then
 call cts40g12_busca_flg_datkassunto(lr_documento.c24astcod)
 returning l_atmacnflg
   else
    let l_atmacnflg = "S"
    let lr_documento.ciaempcod = 1
   end if

   ## Procura viatura somente para os assuntos parametrizados p/ac.automat.
   if l_atmacnflg = "S" then
      if l_criou_tabela = true then

         #servico é via GPS
         #grava todas as naturezas/especialidades do servico em tabtemp
         if cts51g00_temp_naturezas(lr_servicos.*) = true then
            error "Aguarde, pesquisando veiculo ... "
            #chama função para retornar se tem veiculo QRV que possa
            # atender o serviço imediato
            call cts41g00_obtem_veic_para_acionar
                (lr_param.mpacidcod, lr_param.atdsrvorg, lr_param.socntzcod,
                 aux_today, aux_hora, lr_param.lclltt,
                 ###lr_param.data, lr_param.hora, lr_param.lclltt,
                 lr_param.lcllgt,
                 lr_param.atmacnprtcod,
                 lr_param.acnlmttmp,
                 lr_documento.ciaempcod)
                 returning lr_ret.veiculo_aciona, lr_ret.cota_disponivel
            error ""
            if lr_ret.veiculo_aciona is not null then
               let lr_ret.pergunta = "S"
            end if
         end if
      end if
   else
      call ctc59m03_quota_imediato (lr_param.mpacidcod,
                                    lr_param.atdsrvorg,
                                    lr_param.socntzcod,
                                    aux_today, aux_hora)
           returning l_tem_cota
      if l_tem_cota = true then
         # tem cota para hora imediata - perguntar se confirma Imediato
         let lr_ret.cota_disponivel = "S"
         let lr_ret.pergunta = "S"
      else
         let lr_ret.cota_disponivel = "N"
         let lr_ret.pergunta = "N"
      end if

   end if

   return lr_ret.*

end function


#--- Funcao para cidades sem GPS
function cts51g00_cidade_sem_GPS(lr_param)

   define lr_param        record
          mpacidcod       like datkmpacid.mpacidcod,
          atdsrvorg       like datmservico.atdsrvorg,
          socntzcod       like datmsrvre.socntzcod,
          data            like datmservico.atddatprg,
          hora            like datmservico.atdhorprg
   end record

   define l_tem_cota      smallint

   let l_tem_cota = null

   # verificar se tem cota para servico que nao é atendido via GPS

   call ctc59m03_quota_imediato (lr_param.mpacidcod,
                                 lr_param.atdsrvorg,
                                 lr_param.socntzcod,
                                 lr_param.data,
                                 lr_param.hora)
        returning l_tem_cota

   if l_tem_cota = true then
      # tem cota para hora imediata - perguntar se confirma Imediato
      return "S" , l_tem_cota
   else
      return "N" , l_tem_cota
   end if

end function

#PSI202363 - Gravar todas as naturezas e especialidades do
# servico e seus multiplos - essa tabela será lida para verificar
# se há veiculo em QRV q atenda a natureza/especialidade
# e se há serviço para o mesmo horário com mesma natureza/especialidade
#-----------------------------------
function cts51g00_temp_naturezas(param)
#-----------------------------------
  define param record
        socntzcod   like datmsrvre.socntzcod,
        espcod      like datmsrvre.espcod,
        socntzcod_1 like datmsrvre.socntzcod,
        espcod_1    like datmsrvre.espcod,
        socntzcod_2 like datmsrvre.socntzcod,
        espcod_2    like datmsrvre.espcod,
        socntzcod_3 like datmsrvre.socntzcod,
        espcod_3    like datmsrvre.espcod,
        socntzcod_4 like datmsrvre.socntzcod,
        espcod_4    like datmsrvre.espcod,
        socntzcod_5 like datmsrvre.socntzcod,
        espcod_5    like datmsrvre.espcod,
        socntzcod_6 like datmsrvre.socntzcod,
        espcod_6    like datmsrvre.espcod,
        socntzcod_7 like datmsrvre.socntzcod,
        espcod_7    like datmsrvre.espcod,
        socntzcod_8 like datmsrvre.socntzcod,
        espcod_8    like datmsrvre.espcod,
        socntzcod_9 like datmsrvre.socntzcod,
        espcod_9    like datmsrvre.espcod,
        socntzcod_10 like datmsrvre.socntzcod,
        espcod_10    like datmsrvre.espcod
  end record

  define a_natureza array[11] of record
        socntzcod    like datmsrvre.socntzcod,
        espcod       like datmsrvre.espcod
  end record

  define l_linha smallint
  define l_comando char(100)

  #copia dados do param pro array
  let a_natureza[1].socntzcod = param.socntzcod
  let a_natureza[1].espcod = param.espcod
  let a_natureza[2].socntzcod = param.socntzcod_1
  let a_natureza[2].espcod = param.espcod_1
  let a_natureza[3].socntzcod = param.socntzcod_2
  let a_natureza[3].espcod = param.espcod_2
  let a_natureza[4].socntzcod = param.socntzcod_3
  let a_natureza[4].espcod = param.espcod_3
  let a_natureza[5].socntzcod = param.socntzcod_4
  let a_natureza[5].espcod = param.espcod_4
  let a_natureza[6].socntzcod = param.socntzcod_5
  let a_natureza[6].espcod = param.espcod_5
  let a_natureza[7].socntzcod = param.socntzcod_6
  let a_natureza[7].espcod = param.espcod_6
  let a_natureza[8].socntzcod = param.socntzcod_7
  let a_natureza[8].espcod = param.espcod_7
  let a_natureza[9].socntzcod = param.socntzcod_8
  let a_natureza[9].espcod = param.espcod_8
  let a_natureza[10].socntzcod = param.socntzcod_9
  let a_natureza[10].espcod = param.espcod_9
  let a_natureza[11].socntzcod = param.socntzcod_10
  let a_natureza[11].espcod = param.espcod_10

  call cts51g00_del_temp_nat()

  let l_comando = " insert into temp_nat_cts17m00 values (?, ?) "
  prepare p_cts51g00_001 from l_comando

  #inserir naturezas/especialidades na tabela temporária
  for l_linha = 1 to 11
      if a_natureza[l_linha].socntzcod is not null and
         a_natureza[l_linha].socntzcod <> 0 then
         execute p_cts51g00_001 using a_natureza[l_linha].socntzcod,
                                     a_natureza[l_linha].espcod
      else
         exit for
      end if
  end for

  return true

end function

#----------------------------
function cts51g00_cria_temp()
#----------------------------

    whenever error continue
    create temp table temp_nat_cts17m00  #PSI20236 |  Nao alterar nome da tabela temp
           ( socntzcod     smallint, # pois outros modulos utilizam com este nome.
             espcod        smallint
           ) with no log

    whenever error stop

    if sqlca.sqlcode != 0 then
       delete from temp_nat_cts17m00
       #display "erro ao criar temp_nat_cts17m00 ", sqlca.sqlcode,
       #        ' acao=', g_documento.acao sleep 1
       #return
    end if

    return true
end function

#-----------------------------------
function cts51g00_del_temp_nat()
#-----------------------------------

   whenever error continue
   delete from temp_nat_cts17m00
   whenever error stop

end function


#----------------------------------------------------
function cts51g00_ver_existencia_outros_srv(lr_param, d_socntzcod, c_local, l_acaorigem)
#----------------------------------------------------
   define d_socntzcod like datmsrvre.socntzcod,
      l_acaorigem char(3)
   define c_local record
    lclltt like datmlcl.lclltt,
        lgdnom like datmlcl.lgdnom,
        lgdnum like datmlcl.lgdnum,
        brrnom like datmlcl.brrnom,
        cidnom like datmlcl.cidnom,
        ufdcod like datmlcl.ufdcod,
        lgdcep like datmlcl.lgdcep
   end record

   define lr_param       record
          atdsrvnum      like datmservico.atdsrvnum,
          atdsrvano      like datmservico.atdsrvano,
          ramcod         like datrservapol.ramcod,
          succod         like datrservapol.succod,
          aplnumdig      like datrservapol.aplnumdig,
          itmnumdig      like datrservapol.itmnumdig,
          data_cota      like datmservico.atddatprg,
          hora_cota      like datmservico.atdhorprg
   end record

   define lr_srv           record
          etapa            like datmsrvacp.atdetpcod,
          srvrglcod        like datksocntz.socntzgrpcod,
          regatddat        like datmservico.atddat,
          regatdhor        like datmservico.atdhor,
          regsocntzcod     like datmsrvre.socntzcod,
          regatdsrvnum     like datmservico.atdsrvnum,
          regatdsrvano     like datmservico.atdsrvano,
          regsocntzgrpcod  like datksocntz.socntzgrpcod,
          atdlibdat        like datmservico.atdlibdat,
          atdlibhor        like datmservico.atdlibhor,
          atddatprg        like datmservico.atddatprg,
          atdhorprg        like datmservico.atdhorprg
   end record

   define lr_outro_end record
         lclidttxt        like datmlcl.lclidttxt,
         lgdtip           like datmlcl.lgdtip,
         lgdnom           like datmlcl.lgdnom,
         lgdnum           like datmlcl.lgdnum,
         lclbrrnom        like datmlcl.lclbrrnom,
         brrnom           like datmlcl.brrnom,
         cidnom           like datmlcl.cidnom,
         ufdcod           like datmlcl.ufdcod,
         lclrefptotxt     like datmlcl.lclrefptotxt,
         endzon           like datmlcl.endzon,
         lgdcep           like datmlcl.lgdcep,
         lgdcepcmp        like datmlcl.lgdcepcmp,
         lclltt           like datmlcl.lclltt,
         lcllgt           like datmlcl.lcllgt,
         dddcod           like datmlcl.dddcod,
         lcltelnum        like datmlcl.lcltelnum,
         lclcttnom        like datmlcl.lclcttnom,
         c24lclpdrcod     like datmlcl.c24lclpdrcod,
         celteldddcod     like datmlcl.celteldddcod,
         celtelnum        like datmlcl.lcltelnum,
         endcmp           like datmlcl.endcmp,
         codigosql        integer,
         emeviacod        like datmlcl.emeviacod
   end record

   define l_reservar_cota  char(1),
          l_hora_cotac     char(10)

   initialize lr_srv.* to null
   initialize lr_outro_end.*  to  null
   let l_reservar_cota = "S"

   #busca grupo da natureza informada para o servico
   select socntzgrpcod into lr_srv.srvrglcod from datksocntz
          where socntzcod = d_socntzcod

   ### BUSCA SERVICO ANTERIOR COM O MESMO GRUPO DE NATUREZA
   ##verifica outros servicos de origem 9 para a apolice

   declare c_srvant cursor for
      select atddat,
             atdhor,
             socntzcod,
             datmservico.atdsrvnum,
             datmservico.atdsrvano,
             atdlibdat, atdlibhor, atddatprg, atdhorprg
        from datmsrvre, datrservapol, datmservico
       where datrservapol.ramcod     =  lr_param.ramcod
         and datrservapol.succod     =  lr_param.succod
         and datrservapol.aplnumdig  =  lr_param.aplnumdig
         and datrservapol.itmnumdig  =  lr_param.itmnumdig
         and datmsrvre.atdsrvnum     =  datrservapol.atdsrvnum
         and datmsrvre.atdsrvano     =  datrservapol.atdsrvano
         and datmservico.atdsrvnum   =  datrservapol.atdsrvnum
         and datmservico.atdsrvano   =  datrservapol.atdsrvano


   foreach c_srvant into lr_srv.regatddat,
                         lr_srv.regatdhor,
                         lr_srv.regsocntzcod,
                         lr_srv.regatdsrvnum,
                         lr_srv.regatdsrvano,
                         lr_srv.atdlibdat,
                         lr_srv.atdlibhor,
                         lr_srv.atddatprg,
                         lr_srv.atdhorprg

      #despreza servico se este for o mesmo q esta sendo alterado
      if lr_param.atdsrvnum = lr_srv.regatdsrvnum and
         lr_param.atdsrvano = lr_srv.regatdsrvano  then
         continue foreach
      end if

      #despreza servico que foi cancelado
      let lr_srv.etapa = null
      call cts10g04_ultima_etapa (lr_srv.regatdsrvnum, lr_srv.regatdsrvano)
           returning lr_srv.etapa

      if lr_srv.etapa = 5 or
         (lr_srv.etapa =3 and l_acaorigem = "RET") or
         (lr_srv.etapa = 3 and lr_srv.atdlibdat <> lr_param.data_cota) then
         continue foreach
      end if

      #busca grupo da natureza do serviço lido
      select socntzgrpcod into lr_srv.regsocntzgrpcod from datksocntz
       where socntzcod = lr_srv.regsocntzcod

      # se grupo de natureza do servico atual e do
      # servico lido sao iguais

      if lr_srv.srvrglcod = lr_srv.regsocntzgrpcod then

         ## Obter o endereco de ocorrencia do outroservico
         call ctx04g00_local_gps
              (lr_srv.regatdsrvnum, lr_srv.regatdsrvano,1)
              returning lr_outro_end.*

         #se nao teve alteração de endereco
         if (c_local.lclltt is null and lr_outro_end.lclltt is null) or
           (c_local.lclltt is not null and
            c_local.lgdnom = lr_outro_end.lgdnom and
            c_local.lgdnum = lr_outro_end.lgdnum and
            c_local.brrnom = lr_outro_end.brrnom and
            c_local.cidnom = lr_outro_end.cidnom and
            c_local.ufdcod = lr_outro_end.ufdcod and
            c_local.lgdcep = lr_outro_end.lgdcep) then
            let l_reservar_cota = "N"
         else
            #despreza serviço lido se tem endereço diferente
            continue foreach
         end if

         let l_hora_cotac = lr_srv.atdlibhor
         let l_hora_cotac = l_hora_cotac[1,2],":00"
         let lr_srv.atdlibhor = l_hora_cotac

         ## se servico lido esta programado para a
         ## mesma data/hora do servico atual
         ## ou se servico lido é imediato para a hora atual

         if (lr_srv.atddatprg is not null and
             lr_srv.atddatprg = lr_param.data_cota and
             lr_srv.atdhorprg = lr_param.hora_cota) or

            (lr_srv.atddatprg is null and
             lr_srv.atdlibdat = lr_param.data_cota and
             lr_srv.atdlibhor = lr_param.hora_cota) then

             ## nao reservar cota para outro servico
             let l_reservar_cota = "N"
         else
             let l_reservar_cota = "S"
         end if

      end if

   end foreach

   return l_reservar_cota

end function
