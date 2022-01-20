#------------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                              #
# ............................................................................ #
# SISTEMA........: PORTO SOCORRO                                               #
# MODULO.........: WDATN001.4GL                                                #
# ANALISTA RESP..: SERGIO BURINI                                               #
# PSI/OSF........:                                                             #
# OBJETIVO.......: INTERFACE INFORMIX URA CENTRAL DE OPERACOES.                #
# ............................................................................ #
# DESENVOLVIMENTO: SERGIO BURINI                                               #
# LIBERACAO......: 13/11/2008                                                  #
#..............................................................................#
# OBSERVACOES....: O MODULO WDATN001 POSSUI UMA COPIA DA FUNCAO                #
#                  REP_LAUDO_FAX QUE PERTENCE AO MODULO CTS00M14, PORTANTO     #
#                  QUALQUER ALTERACAO EM UM MODULO DEVE SER REPLICADO NO       #
#                  OUTRO                                                       #
# ............................................................................ #
#                        * * *  ALTERACOES  * * *                              #
#                                                                              #
# DATA        AUTOR FABRICA   PSI/OSF       ALTERACAO                          #
# ----------  -------------   ------------  ---------------------------------- #
# 13/08/2009  Sergio Burini   PSI 244236    Inclusao do Sub-Dairro             #
# 30/09/2010  Sergio Burini   PSI 253669    Inclusao do Servico VALIDA_VCL     #
# ---------------------------------------------------------------------------- #
# 25/05/2011  Ueslei Oliveira               Inclusao das funcoes insere etapa  #
#                                           ,historico e atualiza servico,     #
#                                           projeto do novo acionamento        #
# ---------------------------------------------------------------------------- #
# 10/01/2012  Celso Yamahaki                Aumento de '<' no using da funcao  #
#                                           validar_fone_socorrista            #
# ---------------------------------------------------------------------------- #
# 29/02/2012  Celso Yamahaki                Correcao do calculo ano, para      #
#                                           aceitar Bisextos                   #
# ---------------------------------------------------------------------------- #
# 01/05/2012 Fornax  PSI03021PR PSI-2012-03021-PR - Resolucao 553 Anatel       #
# ---------------------------------------------------------------------------- #
# 09/04/2014 CDS Egeu     PSI-2014-02085    Situação Local de Ocorrência       #
#------------------------------------------------------------------------------#
 database porto

 globals  "/homedsa/projetos/geral/globals/glct.4gl"

 define mr_xml record
        flgval  char(01),
        coderr smallint,
        msgerr char(100)
 end record

 define m_servicename char(30),
        m_doc_handle  integer,
        m_xmlrequest  char(32000),
        m_xmlresponse char(32000),
        m_xmlcmp      char(32000),
        wsgpipe       char(00080),
        wsgfax        char(00003),
        m_mensagem_2 char (135),
        m_mensagem_3 char (135),
        m_mensagem_4 char (135),
        m_mensagem_5 char (135),
        m_mensagem_6 char (135)

 define m_subbairro array[03] of record
        lclbrrnom   like datmlcl.lclbrrnom
 end record

 define m_flag smallint
       ,m_grlinf like datkgeral.grlinf


#-------------------------------------#
 function executeService(l_paramxml)
#-------------------------------------#

     define l_paramxml char(32000),
            l_xmlant   char(32000)

     set isolation to dirty read
     set lock mode to wait 20

     initialize m_servicename,
                m_doc_handle,
                m_xmlresponse,
                m_xmlrequest,
                l_xmlant,
                mr_xml.* to null

     let m_xmlrequest = l_paramxml

     let mr_xml.flgval = "N"
     initialize m_xmlcmp to null

     let g_issk.funmat = 999999
     let g_issk.empcod = 1
     let g_issk.usrtip = 'F'

     call startlog("wdatn001.log")

     whenever error continue

        let m_flag = false
          select grlinf
           into m_grlinf
           from datkgeral
          where grlchv = 'PSOURALOCADORA'
        if m_grlinf = 'LIGADO' then
           let m_flag = true
        end if

     whenever error stop

     call figrc011_inicio_parse()
     let m_doc_handle  = figrc011_parse(m_xmlrequest)
     let m_servicename = figrc011_xpath(m_doc_handle,"/REQUEST/SERVICO")

     case m_servicename
         # VALIDACAO DO TELEFONE DO SOCORRISTA
         when "VALIDAR_FONE_SOCORRISTA"
                  call wdatn001_validar_fone_socorrista()

         # VALIDACAO DO SERVICO
         when "VALIDAR_QRU"
                  call wdatn001_validar_qru()

         # BUSCA O CELULAR DO SERVICO EM ATENDIMENTO
         when "BUSCAR_CEL_SEGURADO"
                  call wdatn001_buscar_cel_segurado()

         # BUSCA A SITUACAO DO VEICULO VIA QRA
         when "OBTER_SITUACAO_VEICULO"
                  call wdatn001_obter_situacao_veiculo()

         # RETRANSMISSAO DE SERVICO VIA FAX/PNE/GPS
         when "RETRANSMITIR_SERVICO"
                  call wdatn001_retransmitir_servico()

         # VALIDACAO DO PRAZO DO SERVICO
         when "VALIDA_PRAZO_QRU"
                  call wdatn001_valida_prazo_qru()

         # SERVIÇO DA URA ANTIGA, DEVE SER RETIRADO QUANDO A NOVA URA ENTRAR EM PRODUCAO
         when "VALIDAR_CELULAR_SOCORRISTA"
                  let l_xmlant = wdatn001_fone_seg()

         # ATUALIZACAO DO SERVICO, SINCRONISMO ENTRE O NOVO ACIONAMENTO BASE DE DADOS ORACLE
         when "ATUALIZACAO_SERVICO"
                  call wdatn001_atualiza_servico()

         # INSERE ETAPA DO SERVICO, SINCRONISMO ENTRE O NOVO ACIONAMENTO BASE DE DADOS ORACLE
         when "INCLUIR_SERVICO_ETAPA"
                  call wdatn001_insere_etapa()

         # INSERIR HISTORICO DO SERVICO, SINCRONISMO ENTRE O NOVO ACIONAMENTO BASE DE DADOS ORACLE
         when "INCLUIR_SERVICO_HISTORICO"
                  call wdatn001_insere_historico()

         # DESASSOCIAR SERVICO MULTIPLO NOVO ACIONAMENTO
         when "DESASSOCIAR_SERVICO_MULTIPLO"
                  call wdatn001_desassociar_multiplo()

         # VALIDA CANCELAMENTO DE SERVICO NOVO ACIONAMENTO
         when "VALIDA_CANCELAMENTO_SERVICO"
                  call wdatn001_valida_cancelamento_servico()

         # VALIDA PRIORIZACAO DA LIGACAO DE ACORDO COM ALGUNS DADOS DO SERVICO
         when "VERIFICA_PRIORIDADE_LIGACAO"
                  let l_xmlant = wdatn001_verifica_prioridade_ligacao()

         #Kelly - Inicio - Carga
         #PONTO DE ENTRADA APÓS A GRAVAÇÃO DO SERVIÇO
         WHEN "APOS_GRV_LAUDO"
                  call wdatn001_apos_grv_laudo()
         #Kelly - Fim - Carga

         #Kelly - Inicio - Receber Cancelamento
         #PONTO DE ENTRADA - RECEBER CANCELAMENTO
         WHEN "CANCELAR_ACIONAMENTO"
                  let l_xmlant = wdatn001_cancela_acionamento()
         #Kelly - Fim - Receber Cancelamento

         #Kelly - Inicio - Localizar Prestador
         WHEN "LOCALIZAR_PRESTADOR"
                  let l_xmlant = wdatn001_localizar_prestador()
         #Kelly - Fim - Localizar Prestador

         WHEN "INCLUIR_TELEFONE_SOCORRISTA"
                  let l_xmlant = wdatn001_incluir_telefone_socorrista()

         WHEN "INCLUIR_TELEFONE_VEICULO"
                  let l_xmlant = wdatn001_incluir_telefone_veiculo()

         WHEN "INCLUIR_TELEFONE_BASE"
                  let l_xmlant = wdatn001_incluir_telefone_base()
         #Busca o QRA do socorrista pelo CPF
         WHEN "OBTER_QRA_SOCORRISTA"
                  let l_xmlant = wdatn001_obter_qra_socorrista()
         WHEN "BLOQUEAR_SERVICO"
                  call wdatn001_bloquear_servico()
         WHEN "DESBLOQUEAR_SERVICO"
                  call wdatn001_desbloquear_servico()

         WHEN "CLIENTE_PREMIUM"
                  call wdatn001_cliente_premium()
                       returning l_xmlant
         otherwise
                  let mr_xml.coderr = 1
                  let mr_xml.msgerr = "Serviço MQ não encontrado: ",m_servicename clipped
     end case

     if  l_xmlant is null or l_xmlant = " " then
         call wdatn001_monta_xml()
     else
         let m_xmlresponse = l_xmlant
     end if

     call figrc011_fim_parse()

     return m_xmlresponse

 end function

#-------------------------------------------#
 function wdatn001_validar_fone_socorrista()
#-------------------------------------------#

     define lr_xml record
         dddtel    like datksrr.celdddcod,
         numtel    like datksrr.celtelnum,
         srrcoddig like datksrr.srrcoddig,
         socvclcod like datkveiculo.socvclcod,
         atdsrvnum like datmservico.atdsrvnum,
         atdsrvano like datmservico.atdsrvano
     end record

     initialize lr_xml.* to null

     # EXTRAI DADOS DO XML
     let lr_xml.dddtel = figrc011_xpath(m_doc_handle, "/REQUEST/FONE/DDD")
     let lr_xml.numtel = figrc011_xpath(m_doc_handle, "/REQUEST/FONE/NUMERO")

     # VERIFICA SE O TELEFONE PERTENTE A ALGUMA VIATURA.
     whenever error continue
     select distinct socvclcod
       into lr_xml.socvclcod
       from datkveiculo
      where (celdddcod = lr_xml.dddtel and celtelnum = lr_xml.numtel)
         or (nxtdddcod = lr_xml.dddtel and nxtnum    = lr_xml.numtel)
     whenever error stop

     if  sqlca.sqlcode = 0 then

         # BUSCA O QRA QUE ESTA ATENDENDO NA VIATURA
         whenever error continue
         select srrcoddig
           into lr_xml.srrcoddig
           from dattfrotalocal
          where socvclcod = lr_xml.socvclcod
         whenever error stop

         let mr_xml.flgval  = "S"
     else
         if  sqlca.sqlcode = 100 then

             # VERIFICA SE O TELEFONE PERTENTE A ALGUM SOCORRISTA.
             whenever error continue
             select distinct srrcoddig
               into lr_xml.srrcoddig
               from datksrr
              where (celdddcod = lr_xml.dddtel and celtelnum = lr_xml.numtel)
                 or (nxtdddcod = lr_xml.dddtel and nxtnum    = lr_xml.numtel)
             whenever error stop

             if  sqlca.sqlcode = 100 then
                 display "NAO ACHOU SOCORRISTA/VEICULO: ", lr_xml.dddtel, "/", lr_xml.numtel
             else
                 if  sqlca.sqlcode = 0 then
                     let mr_xml.flgval  = "S"
                 else
                     display "ERRO: ", sqlca.sqlcode, " SELECT tabela datksrr"
                 end if
             end if
         else
             display "ERRO: ", sqlca.sqlcode, " SELECT tabela datkveiculo"
         end if
     end if

     if  mr_xml.flgval = "S" then

         # BUSCA SERVIÇO EM ATENDIMENTO
         whenever error continue
         select atdsrvnum,
                atdsrvano
           into lr_xml.atdsrvnum,
                lr_xml.atdsrvano
           from dattfrotalocal
          where srrcoddig  = lr_xml.srrcoddig
         whenever error stop

         let m_xmlcmp = "<QRU>",
                           "<NUMERO>", lr_xml.atdsrvnum using  "<<<<<<<", "</NUMERO>",
                           "<ANO>", lr_xml.atdsrvano using "<<","</ANO>",
                        "</QRU>",
                        "<QRA>",
                           "<NUMERO>", lr_xml.srrcoddig using "<<<<<<<<", "</NUMERO>",
                        "</QRA>"


         let mr_xml.coderr = 0
         let mr_xml.msgerr = "Celular encontrado na base Porto Socorro"

     else
         let mr_xml.coderr = 100
         let mr_xml.msgerr = "Celular nao encontrado na base Porto Socorro"
     end if

 end function

#----------------------------------#
 function wdatn001_validar_qru()
#----------------------------------#

     define lr_xml record
         atdsrvnum char(20)
     end record

     define lr_aux record
         anocurr smallint,
         anoant  smallint,
         tamanho smallint,
         anohj   integer
     end record

     initialize lr_aux.* to null

     # EXTRAI DADOS DO XML
     let lr_xml.atdsrvnum = figrc011_xpath(m_doc_handle, "/REQUEST/QRU/NUMERO")

     let m_xmlcmp = ""

     let lr_aux.tamanho = length(lr_xml.atdsrvnum)

     if  length(lr_xml.atdsrvnum) < 7 then
         let mr_xml.coderr = 4
         let mr_xml.msgerr = "Parametros invalidos"
     else
         # VERIFICA SE O SERVICO EXISTE
         # MOD 100 PARA PEGAR OS DOIS ULTIMOS DIGITOS
         let lr_aux.anohj = year(current) mod 100
         let lr_aux.anocurr = lr_aux.anohj
         let lr_aux.anoant  = lr_aux.anocurr - 1

         whenever error continue
         select 1
           from datmservico srv1
          where srv1.atdsrvnum = lr_xml.atdsrvnum
            and srv1.atdsrvano = (select max(atdsrvano)
                                    from datmservico srv2
                                   where srv2.atdsrvnum = srv1.atdsrvnum
                                     and atdsrvano between lr_aux.anoant and lr_aux.anocurr)
         whenever error stop

         if  sqlca.sqlcode = 0 then
             let mr_xml.flgval = "S"
             let mr_xml.coderr = 0
             let mr_xml.msgerr = "Serviço encontrado na base Porto Socorro"
         else
             if  sqlca.sqlcode <> 100 then
                 display "ERRO: ", sqlca.sqlcode, " SELECT tabela datmservico"
             end if

             let mr_xml.coderr = sqlca.sqlcode
             let mr_xml.msgerr = "Serviço não encontrado na base Porto Socorro"

         end if
     end if

 end function

#---------------------------------------#
 function wdatn001_buscar_cel_segurado()
#---------------------------------------#

     define lr_xml record
         atdsrvnum like datmservico.atdsrvnum,
         dddcod    like datmlcl.dddcod,
         numtel    like datmlcl.lcltelnum
     end record

     define lr_aux record
         atdsrvano    like datmlcl.atdsrvano,
         celteldddcod like datmlcl.celteldddcod,
         celtelnum    like datmlcl.celtelnum,
         dddcod       like datmlcl.dddcod,
         lcltelnum    like datmlcl.lcltelnum,
         ctttelnum    like datmavisrent.ctttelnum,
         smsenvdddnum like datmavisrent.smsenvdddnum,
         smsenvcelnum like datmavisrent.smsenvcelnum
     end record

     define lr_erro record
            errcod  smallint,
            errmsg  char(100)
     end record
     define l_flag smallint
     define l_lighorinc    like datmservhist.lighorinc

     let l_lighorinc = null

     initialize lr_aux.*,
                lr_erro.*,
                lr_xml.* to null

     # EXTRAI DADOS DO XML
     let lr_xml.atdsrvnum = figrc011_xpath(m_doc_handle, "/REQUEST/QRU/NUMERO")

     # BUSCA TELEFONE DO SEGURADO EM ATENDIMENTO
     select atdsrvano,
            celteldddcod,
            celtelnum,
            dddcod,
            lcltelnum
       into lr_aux.atdsrvano,
            lr_aux.celteldddcod,
            lr_aux.celtelnum,
            lr_aux.dddcod,
            lr_aux.lcltelnum
       from datmlcl lcl
      where lcl.atdsrvnum = lr_xml.atdsrvnum
        and lcl.atdsrvano = (select max(atdsrvano)
                               from datmservico srv
                              where lcl.atdsrvnum = srv.atdsrvnum)
        and c24endtip = 1

     if  sqlca.sqlcode = 0 then

         if  lr_aux.celteldddcod is not null and lr_aux.celteldddcod <> 0 and
             lr_aux.celtelnum    is not null and lr_aux.celtelnum <> 0 then

             let lr_xml.dddcod = lr_aux.celteldddcod
             let lr_xml.numtel = lr_aux.celtelnum

         else
             if  lr_aux.dddcod    is not null and lr_aux.dddcod    <> 0 and
                 lr_aux.lcltelnum is not null and lr_aux.lcltelnum <> 0 then

                 let lr_xml.dddcod = lr_aux.dddcod
                 let lr_xml.numtel = lr_aux.lcltelnum

             else

                 let mr_xml.coderr = 100
                 let mr_xml.msgerr = "Serviço não encontrado na base Porto Socorro"

                 return

             end if
         end if

         let m_xmlcmp = "<FONE>",
                           "<DDD>", lr_xml.dddcod using "<<<<", "</DDD>",
                           "<NUMERO>", lr_xml.numtel using "<<<<<<<<<<", "</NUMERO>",
                        "</FONE>"

         let mr_xml.flgval = "S"
         let mr_xml.coderr = 0
         let mr_xml.msgerr = "Serviço encontrado na base Porto Socorro"

				 let l_lighorinc = current
         call ctd07g01_ins_datmservhist(lr_xml.atdsrvnum,
                                        lr_aux.atdsrvano,
                                        999999,
                                        "Contato do Socorrista com o Segurado atraves da URA CO.",
                                        today,
                                        l_lighorinc,
                                        1,
                                        'F')
              returning lr_erro.errcod,
                        lr_erro.errmsg

         if  lr_erro.errcod <> 1 then
             display "ERRO ", lr_erro.errcod , " - ", lr_erro.errmsg, " SERVICO: BUSCAR_CEL_SEGURADO"
         end if
     else
         if m_flag then
            #Para serviços de carro reserva
            select dddcod, telnum,
                   cttdddcod, ctttelnum,
                   smsenvdddnum, smsenvcelnum, atdsrvano
              into lr_aux.celteldddcod,
                   lr_aux.celtelnum,
                   lr_aux.dddcod,
                   lr_aux.ctttelnum,
                   lr_aux.smsenvdddnum,
                   lr_aux.smsenvcelnum,
                   lr_aux.atdsrvano
              from datmavisrent rnt1
             where rnt1.atdsrvnum = lr_xml.atdsrvnum
               and rnt1.atdsrvano = (select max(atdsrvano)
                                  from datmservico rnt2
                                 where rnt2.atdsrvnum = rnt1.atdsrvnum)
            if sqlca.sqlcode = 0 then
            	  #Converte variavel de banco char para decimal
            	  whenever error continue
            	  let lr_aux.lcltelnum = lr_aux.ctttelnum
            	  whenever error stop

                if  lr_aux.celteldddcod is not null and lr_aux.celteldddcod <> 0 and
                    lr_aux.celtelnum    is not null and lr_aux.celtelnum <> 0 then

                    let lr_xml.dddcod = lr_aux.celteldddcod
                    let lr_xml.numtel = lr_aux.celtelnum

                else
                    if  lr_aux.dddcod    is not null and lr_aux.dddcod    <> 0 and
                        lr_aux.lcltelnum is not null and lr_aux.lcltelnum <> 0 then

                        let lr_xml.dddcod = lr_aux.dddcod
                        let lr_xml.numtel = lr_aux.lcltelnum

                    else
                        if lr_aux.smsenvdddnum  is not null and lr_aux.smsenvdddnum <> 0 and
                           lr_aux.smsenvcelnum  is not null and lr_aux.smsenvcelnum <> 0 then

                           let lr_xml.dddcod = lr_aux.smsenvdddnum
                           let lr_xml.numtel = lr_aux.smsenvcelnum

                        else
                              let mr_xml.coderr = 100
                              let mr_xml.msgerr = "Serviço não encontrado na base Porto Socorro"

                              return
                        end if
                    end if
                end if

                let m_xmlcmp = "<FONE>",
                              "<DDD>", lr_xml.dddcod using "<<<<", "</DDD>",
                              "<NUMERO>", lr_xml.numtel using "<<<<<<<<<<", "</NUMERO>",
                           "</FONE>"

                let mr_xml.flgval = "S"
                let mr_xml.coderr = 0
                let mr_xml.msgerr = "Serviço encontrado na base Porto Socorro"

								let  l_lighorinc = current
                call ctd07g01_ins_datmservhist(lr_xml.atdsrvnum,
                                               lr_aux.atdsrvano,
                                               999999,
                                               "Contato da Locadora com o Segurado atraves da URA CO.",
                                               today,
                                               l_lighorinc,
                                               1,
                                               'F')
                     returning lr_erro.errcod,
                               lr_erro.errmsg

                if  lr_erro.errcod <> 1 then
                    display "ERRO ", lr_erro.errcod , " - ", lr_erro.errmsg, " SERVICO: BUSCAR_CEL_SEGURADO"
                end if

            else
               if  sqlca.sqlcode <> 100 then
                   display "ERRO: ", sqlca.sqlcode, " SELECT tabela datmservico"
               end if

         let mr_xml.coderr = 100
         let mr_xml.msgerr = "Serviço não encontrado na base Porto Socorro"

            end if

         else
             if  sqlca.sqlcode <> 100 then
                 display "ERRO: ", sqlca.sqlcode, " SELECT tabela datmservico"
             end if

             let mr_xml.coderr = 100
             let mr_xml.msgerr = "Serviço não encontrado na base Porto Socorro"

         end if
     end if

 end function

#------------------------------------------#
 function wdatn001_obter_situacao_veiculo()
#------------------------------------------#

     define lr_xml record
         srrcoddig like datmservico.atdsrvnum,
         c24atvcod like dattfrotalocal.c24atvcod
     end record

     define lr_aux record
         caddat    like datmmdtmvt.caddat,
         cadhor    like datmmdtmvt.cadhor,
         hormvtstg char(20),
         hormvt    datetime year to second,
         horcur    datetime year to second,
         total     datetime year to second,
         grlchv    like datkgeral.grlchv,
         grlinf    like datkgeral.grlinf
     end record

     initialize lr_xml.*,
                lr_aux.* to null

     # EXTRAI DADOS DO XML
     let lr_xml.srrcoddig = figrc011_xpath(m_doc_handle, "/REQUEST/QRA/NUMERO")

     # VERIFICA A SITUACAO DO VEICULO NA TABELA DA FROTA
     # whenever error continue
     # select c24atvcod
     #   into lr_xml.c24atvcod
     #   from dattfrotalocal a
     #  where srrcoddig = lr_xml.srrcoddig
     #    and cttdat in (select max(cttdat)
     #                     from dattfrotalocal b
     #                    where a.srrcoddig  = b.srrcoddig)
     #    and ctthor in (select max(ctthor)
     #                     from dattfrotalocal b
     #                    where a.srrcoddig  = b.srrcoddig
     #                      and b.cttdat     = a.cttdat)
     # whenever error stop

     #whenever error continue
     #select mvt.caddat,
     #       mvt.cadhor,
     #       mvt.lclltt,
     #       mvt.lcllgt
     #  into lr_aux.caddat,
     #       lr_aux.cadhor,
     #       lr_aux.lclltt,
     #       lr_aux.lcllgt
     #  from dattfrotalocal frt,
     #       datkveiculo    vcl,
     #       datmmdtmvt     mvt
     # where frt.srrcoddig = lr_xml.srrcoddig
     #   and frt.socvclcod = vcl.socvclcod
     #   and vcl.mdtcod    = mvt.mdtcod
     #   and mvt.mdtmvtstt = 2
     #   and mvt.mdtmvtseq = (select max(mvt2.mdtmvtseq)
     #                          from datmmdtmvt mvt2
     #                         where mvt2.mdtcod = mvt.mdtcod)
     #whenever error stop

     whenever error continue
     select pos.atldat,
            pos.atlhor
       into lr_aux.caddat,
            lr_aux.cadhor
       from dattfrotalocal frt,
            datmfrtpos     pos
      where frt.srrcoddig    = lr_xml.srrcoddig
        and pos.socvclcod    = frt.socvclcod
        and pos.socvcllcltip = 1
        and frt.c24atvcod not in ('QTP','NIL')
     whenever error stop

     if  sqlca.sqlcode = 0 then

         let lr_aux.grlchv = 'PSOLIMSITMVT'

         whenever error continue
         select grlinf
           into lr_aux.grlinf
           from datkgeral
          where grlchv = lr_aux.grlchv
         whenever error stop

         if  sqlca.sqlcode = 0 then

             let lr_aux.hormvtstg = year(lr_aux.caddat) using "<<&&&&","-",
                                    month(lr_aux.caddat)using "<<<<&&","-",
                                    day(lr_aux.caddat)  using "<&&"," ",
                                    lr_aux.cadhor

             let lr_aux.hormvt = lr_aux.hormvtstg
             let lr_aux.horcur = current

             let lr_aux.total = lr_aux.hormvt + lr_aux.grlinf units minute

             if  lr_aux.horcur < lr_aux.hormvt + lr_aux.grlinf units minute then
                 let mr_xml.flgval = "S"
                 let mr_xml.coderr = 0
                 let mr_xml.msgerr = "Validação da viatura realizada com sucesso."
             else
                 let mr_xml.flgval = "N"
                 let mr_xml.coderr = 9
                 let mr_xml.msgerr = "Ultimo sinal valido excede os  ", lr_aux.grlinf using "<<<&", " minutos de tolerancia."
             end if
         else
             let mr_xml.coderr = 100
             let mr_xml.msgerr = "Parametro PSOLIMSITMVT nao encontrado na base Porto Socorro."
         end if
     else
         let mr_xml.coderr = 100
         let mr_xml.msgerr = "Posição da Frota não encontrada na base Porto Socorro."
     end if

 end function

#----------------------------------------#
 function wdatn001_retransmitir_servico()
#----------------------------------------#

     define lr_xml record
         atdsrvnum like datmservico.atdsrvnum,
         atdsrvano like datmservico.atdsrvano,
         tipenv    like dattfrotalocal.c24atvcod
     end record

     define lr_erro record
            errcod  smallint,
            errmsg  char(100)
     end record

     define l_msg char(100),
            l_txttiptrx char(20),
            l_atdsrvseq like datmsrvacp.atdsrvseq

     initialize lr_xml.*,
                lr_erro.*,
                l_msg,
                l_txttiptrx,
                l_atdsrvseq to null

     let lr_xml.atdsrvnum = figrc011_xpath(m_doc_handle, "/REQUEST/QRU/NUMERO")
     let lr_xml.tipenv    = figrc011_xpath(m_doc_handle, "/REQUEST/TIPO_RETRANSMISSAO")

     select max(atdsrvano)
       into lr_xml.atdsrvano
       from datmservico
      where atdsrvnum = lr_xml.atdsrvnum

     #--------------------------------------------------------------------
     # Verifica se o AcionamentoWeb esta ativo e se a origem do servico faz parte do AcionamentoWeb
     #--------------------------------------------------------------------
     if ctx34g00_ver_acionamentoWEB(2) and ctx34g00_origem(lr_xml.atdsrvnum,lr_xml.atdsrvano) then

       ## REENVIA TRANSMISSAO AW
       let l_txttiptrx = lr_xml.tipenv
       if l_txttiptrx = "PNE" then
       	  # INTERNET
          let l_txttiptrx = 'INTERNET'
       end if

       select max(atdsrvseq)
       into l_atdsrvseq
       from datmsrvacp
      where atdsrvnum = lr_xml.atdsrvnum
        and atdsrvano = lr_xml.atdsrvano

       call ctx34g02_reenviar_conclusao(lr_xml.atdsrvnum,
                                        lr_xml.atdsrvano,
                                        l_atdsrvseq,
                                        l_txttiptrx,
                                        g_issk.usrtip,
                                        g_issk.empcod,
                                        g_issk.funmat)
            returning mr_xml.coderr,
                      mr_xml.msgerr

       if mr_xml.coderr is null then
          let mr_xml.coderr   = 0
       end if

       if mr_xml.coderr = 0 then
          let mr_xml.msgerr   = "Serviço retransmitido com sucesso"
          let mr_xml.flgval   = "S"
       end if

     else

 	     case lr_xml.tipenv
          when "GPS"

                call wdatn001_enviagps(lr_xml.atdsrvnum,
                                       lr_xml.atdsrvano)

          when "FAX"

                call wdatn001_enviafax(lr_xml.atdsrvnum,
                                       lr_xml.atdsrvano)

          when "PNE"

               call  wdatn001_enviapne(lr_xml.atdsrvnum,
                                       lr_xml.atdsrvano)

          otherwise

              let mr_xml.coderr = 100
              let mr_xml.msgerr = "Tipo de retransmissão nao encontrada."

       end case
     end if

     if  mr_xml.coderr = 0 then

         let l_msg = "Servico retransmitido via "

         if  lr_xml.tipenv = 'PNE' then
             let l_msg = l_msg clipped, " Portal de Negocios"
         else
             let l_msg = l_msg clipped, " ", lr_xml.tipenv
         end if

         let l_msg = l_msg clipped, " após solicitação "

         call cts10g02_historico(lr_xml.atdsrvnum,
                                 lr_xml.atdsrvano,
                                 today,
                                 current,
                                 999999,
                                 l_msg,
                                 "do prestador via URA da CO.",
                                 "","","")
                       returning lr_erro.errcod

         if  lr_erro.errcod <> 1 then
             display "ERRO ", lr_erro.errcod , " - ", lr_erro.errmsg, " SERVICO: RETRANSMITIR_SERVICO"
         end if
     end if

 end function

#------------------------------------#
 function wdatn001_valida_prazo_qru()
#------------------------------------#

     define lr_xml record
         atdsrvnum like datmservico.atdsrvnum
     end record

     define lr_aux record
         atdsrvorg       like datmservico.atdsrvorg,
         srvprsacnhordat like datmservico.srvprsacnhordat,
         grlchv          like datkgeral.grlchv,
         grlinf          like datkgeral.grlinf,
         aviretdat       like datmavisrent.aviretdat,
         avirethor       like datmavisrent.avirethor,
         hora            char(05)
     end record
     define lr_data_hora record
          completo like datmservico.srvprsacnhordat,
          hora    char(2)  ,
          minuto  char(2)
    end record

     initialize lr_aux.*, lr_data_hora.* to null

     let lr_xml.atdsrvnum = figrc011_xpath(m_doc_handle, "/REQUEST/QRU/NUMERO")

     # VERIFICA A DATA DE ACIONAMENTO
     whenever error continue
     select atdsrvorg,
            srvprsacnhordat
       into lr_aux.atdsrvorg,
            lr_aux.srvprsacnhordat
       from datmservico srv1
      where srv1.atdsrvnum = lr_xml.atdsrvnum
        and srv1.atdsrvano = (select max(atdsrvano)
                                from datmservico srv2
                               where srv2.atdsrvnum = srv1.atdsrvnum)
     whenever error stop

     if  sqlca.sqlcode = 0 then

         if  lr_aux.atdsrvorg = 9 or
             lr_aux.atdsrvorg = 13 then
             let lr_aux.grlchv = 'PSOLIMEXCRE'
         else
             let lr_aux.grlchv = 'PSOLIMEXCAUTO'

         end if

         if m_flag then
            if lr_aux.atdsrvorg = 8 then #Para serviços de carro reserva
               let lr_aux.grlchv = 'PSOLIMCXT'

               select aviretdat, avirethor
                 into lr_aux.aviretdat, lr_aux.avirethor
                 from datmavisrent rnt1
                where rnt1.atdsrvnum = lr_xml.atdsrvnum
                  and rnt1.atdsrvano = (select max(atdsrvano)
                                     from datmservico rnt2
                                    where rnt2.atdsrvnum = rnt1.atdsrvnum)

            end if
         end if

         whenever error continue
         select grlinf
           into lr_aux.grlinf
           from datkgeral
          where grlchv = lr_aux.grlchv
         whenever error stop

         if  sqlca.sqlcode = 0 then
             if m_flag then
                if lr_aux.atdsrvorg = 8 then
                   let lr_data_hora.hora   =  extend(lr_aux.avirethor, hour to hour)
                   let lr_data_hora.minuto =  extend(lr_aux.avirethor, minute to minute)
                   let lr_data_hora.completo = lr_aux.aviretdat

                   let lr_data_hora.completo = lr_data_hora.completo + lr_data_hora.hora units hour + lr_data_hora.minuto units minute


                   let lr_aux.srvprsacnhordat =  lr_data_hora.completo
                end if
             end if

             if  (lr_aux.srvprsacnhordat + lr_aux.grlinf units hour) > current then
                 let mr_xml.flgval = "S"
             end if

             let lr_aux.srvprsacnhordat = lr_aux.srvprsacnhordat + lr_aux.grlinf units hour

         end if
     else
         display "SERVICO NAO ENCONTRADO."
     end if

 end function

#------------------------------------#
 function wdatn001_enviagps(lr_param)
#------------------------------------#

     define lr_param record
         atdsrvnum like datmservico.atdsrvnum,
         atdsrvano like datmservico.atdsrvano
     end record

     define lr_aux record
         socvclcod like datmservico.socvclcod,
         mdtmsgnum like datmmdtmsg.mdtmsgnum,
         laudo     char(4000),
         mdtcod    integer,
         tabname   like systables.tabname,
         sqlcode   integer
     end record

     select socvclcod
       into lr_aux.socvclcod
       from datmservico
      where atdsrvnum = lr_param.atdsrvnum
        and atdsrvano = lr_param.atdsrvano

     call cts00g02_laudo(lr_param.atdsrvnum,
                         lr_param.atdsrvano,
                         lr_aux.socvclcod)
          returning lr_aux.laudo,
                    lr_aux.mdtcod,
                    lr_aux.tabname,
                    lr_aux.sqlcode


     if lr_aux.mdtcod is null or lr_aux.mdtcod = " " then
             let mr_xml.coderr = 100
             let mr_xml.msgerr = "LAUDO NAO ENCONTRADO."
     else
         if  lr_aux.sqlcode = 0 then

         begin work

         #INSERE NA TABELA DE MENSAGEM DE MDT
         insert into datmmdtmsg (mdtmsgnum,
                                 mdtmsgorgcod,
                                 mdtcod,
                                 mdtmsgstt,
                                 mdtmsgavstip )
                       values   (0,
                                 1,
                                 lr_aux.mdtcod,
                                 1,              #--> Aguardando transmissao
                                 3 )             #--> Sinal bip e sirene

         if  sqlca.sqlcode = 0 then

             let lr_aux.mdtmsgnum  =  sqlca.sqlerrd[2]

             # INSERE NA TABELA DE LOG DE MENSAGEM
             insert into datmmdtlog (mdtmsgnum,
                                     mdtlogseq,
                                     mdtmsgstt,
                                     atldat,
                                     atlhor,
                                     atlemp,
                                     atlmat )
                            values  (lr_aux.mdtmsgnum,
                                     1,
                                     1,
                                     current,
                                     current,
                                     1,
                                     999999 )

             if  sqlca.sqlcode = 0 then

                 # INSERE NA TABELA DE TEXTO DE MENSAGEM
                 insert into datmmdtmsgtxt (mdtmsgnum,
                                            mdtmsgtxtseq,
                                            mdtmsgtxt )
                                   values  (lr_aux.mdtmsgnum,
                                            1,
                                            lr_aux.laudo)

                 if  sqlca.sqlcode = 0 then
                     commit work
                     let mr_xml.coderr   = 0
                     let mr_xml.msgerr   = "Serviço retransmitido com sucesso"
                     let mr_xml.flgval   = "S"
                 else
                     rollback work
                     let mr_xml.coderr = 100
                     let mr_xml.msgerr = "Serviço não encontrado na base Porto Socorro"
                 end if
             else
                rollback work
                let mr_xml.coderr = 100
                let mr_xml.msgerr = "Serviço não encontrado na base Porto Socorro"
             end if
         else
             rollback work
             let mr_xml.coderr = 100
             let mr_xml.msgerr = "Serviço não encontrado na base Porto Socorro"
         end if
     else
         let mr_xml.coderr = 100
         let mr_xml.msgerr = "LAUDO NAO ENCONTRADO."
         end if
     end if

 end function

#------------------------------------#
 function wdatn001_enviafax(lr_param)
#------------------------------------#

     define lr_param record
         atdsrvnum like datmservico.atdsrvnum,
         atdsrvano like datmservico.atdsrvano
     end record

     define lr_aux record
         atdprscod like datmservico.atdprscod,
         dddfax    like dpaksocor.dddcod,
         faxnum    like dpaksocor.faxnum,
         nomgrr    like dpaksocor.nomgrr,
         envflg    smallint,
         faxch1    char(025),
         faxtxt    char(012),
         faxch2    like gfxmfax.faxch2
     end record

     initialize wsgpipe,
                wsgfax to null

     let wsgfax = "VSI"

     whenever error continue
     select atdprscod
       into lr_aux.atdprscod
       from datmservico srv
      where atdsrvnum = lr_param.atdsrvnum
        and atdsrvano = lr_param.atdsrvano
        and atdsrvorg <> 18
     whenever error stop

     if  sqlca.sqlcode = 0 then

         whenever error continue
         select dddcod,
                faxnum,
                nomgrr
           into lr_aux.dddfax,
                lr_aux.faxnum,
                lr_aux.nomgrr
           from dpaksocor
          where pstcoddig = lr_aux.atdprscod
         whenever error stop

         #let lr_aux.dddfax = 11
         #let lr_aux.faxnum = 33668630

         if  sqlca.sqlcode = 0 then

             let lr_aux.faxch1 = lr_param.atdsrvnum using "&&&&&&&&",
                                 lr_param.atdsrvano using "&&"

             whenever error continue
             select max(faxch2)
               into lr_aux.faxch2
               from datmfax
              where datmfax.faxsiscod = "CT"  and
                    datmfax.faxsubcod = 'PS'  and
                    datmfax.faxch1    = lr_aux.faxch1
             whenever error continue

             if  sqlca.sqlcode = 0 then

                 if  lr_aux.faxch2  is null   then
                     let lr_aux.faxch2 = 0
                 end if

                 let lr_aux.faxch2 = lr_aux.faxch2 + 1

                 whenever error continue
                 insert into datmfax ( faxsiscod,
                                       faxsubcod,
                                       faxch1   ,
                                       faxch2   ,
                                       faxenvdat,
                                       faxenvhor,
                                       funmat   ,
                                       faxenvsit )
                             values  ( "CT"     ,
                                       "PS" ,
                                       lr_aux.faxch1,
                                       lr_aux.faxch2,
                                       today,
                                       current hour to second,
                                       "999999",
                                       1)
                 whenever error stop

                 if  sqlca.sqlcode = 0 then



                     call cts02g01_fax(lr_aux.dddfax, lr_aux.faxnum)
                          returning lr_aux.faxtxt

                     let wsgpipe = "vfxCTPS ", lr_aux.faxtxt clipped," ",
                                   ASCII 34, lr_aux.nomgrr clipped,
                                   ASCII 34, " ", lr_aux.faxch1 using "&&&&&&&&&&",
                                   " ", lr_aux.faxch2 using "&&&&&&&&&&"

                     start report rep_laudo_fax

                     output to report rep_laudo_fax(lr_param.atdsrvnum,
                                                    lr_param.atdsrvano ,
                                                    lr_aux.dddfax,
                                                    lr_aux.faxnum,
                                                    "F",
                                                    lr_aux.nomgrr,
                                                    lr_aux.faxch1,
                                                    lr_aux.faxch2)

                     finish report rep_laudo_fax

                     let mr_xml.flgval = "S"
                     let mr_xml.coderr = 0
                     let mr_xml.msgerr = "Serviço retransmitido via FAX com sucesso."

                     return

                 else
                     display "PROBLEMA NA INCLUSAO DA TABELA DE FAX"
                 end if
             else
                 display "PROBLEMA NA TABELA DE FAX"
             end if
         else
             display "NUMERO DE FAX NAO LOCALIZADO."
         end if
     else
         display "PRESTADOR NAO ENCONTRADO."
     end if

     let mr_xml.coderr = 100
     let mr_xml.msgerr = "Serviço não encontrado na base Porto Socorro"

 end function

#------------------------------------#
 function wdatn001_enviapne(lr_param)
#------------------------------------#

     define lr_param record
         atdsrvnum like datmservico.atdsrvnum,
         atdsrvano like datmservico.atdsrvano
     end record

     define lr_aux record
         atdprscod like datmservico.atdprscod,
         ciaempcod like datmservico.ciaempcod
     end record

     initialize lr_aux.* to null

     whenever error continue
     select ciaempcod,
            atdprscod
       into lr_aux.ciaempcod,
            lr_aux.atdprscod
       from datmservico srv
      where atdsrvnum = lr_param.atdsrvnum
        and atdsrvano = lr_param.atdsrvano
     whenever error stop

     if  sqlca.sqlcode = 0 then

         #INSERE NA TABELA DE COMPLEMENTO DO SERVICO-WEB
         whenever error continue
         insert into datmsrvintcmp (atdsrvnum,
                                    atdsrvano,
                                    caddat   ,
                                    cadhor   ,
                                    cadorg   ,
                                    cadmat   ,
                                    cademp   ,
                                    cadusrtip,
                                    atlemp   ,
                                    atlusrtip,
                                    atlmat   ,
                                    atldat   ,
                                    atlhor   ,
                                    srvcmptxt,
                                    pstcoddig)
                                 values
                                   (lr_param.atdsrvnum,
                                    lr_param.atdsrvano,
                                    today           ,
                                    current,
                                    0       ,
                                    999999   ,
                                    lr_aux.ciaempcod   ,
                                    'F'   ,
                                    "","","","",""  ,
                                    "RETRANSMISSAO DE SERVICO SOLICITADO PELA URA",
                                    lr_aux.atdprscod)
         whenever error stop

         if  sqlca.sqlcode  = 0 then
             let mr_xml.flgval = "S"
             let mr_xml.coderr = 0
             let mr_xml.msgerr = "Serviço retransmitido via PNE com sucesso."
         end if
     else
         display "SERVIÇO NAO ENCONTRADO."
     end if

 end function

#-----------------------------#
 function wdatn001_monta_xml()
#-----------------------------#

     let m_xmlresponse = "<RESPONSE>",
                            "<SERVICO>", m_servicename clipped, "</SERVICO>",
                            "<VALIDO>", mr_xml.flgval, "</VALIDO>",
                            m_xmlcmp clipped,
                            "<ERRO>",
                               "<NUMERO>", mr_xml.coderr using "<<<&", "</NUMERO>",
                               "<MENSAGEM>", mr_xml.msgerr clipped, "</MENSAGEM>",
                            "</ERRO>",
                         "</RESPONSE>"

 end function

# FUNCAO COPIA DO ENVIO DE FAX ORIGINAL SEPARADA
# DEVIDO A PROBLEMAS DE COMPILAÇÃO/LINKEDIÇÃO
#--------------------------------#
 report rep_laudo_fax(r_cts00m14)
#--------------------------------#

 define r_cts00m14    record
    atdsrvnum         like datmservico.atdsrvnum   ,
    atdsrvano         like datmservico.atdsrvano   ,
    dddcod            like dpaksocor.dddcod        ,
    faxnum            dec (10,0)                   ,
    enviar            char (01)                    ,
    nomgrr            char (24)                    ,
    faxch1            like gfxmfax.faxch1          ,
    faxch2            like gfxmfax.faxch2
 end record

 define ws            record
    atdsrvorg         like datmservico.atdsrvorg   ,
    asitipcod         like datmservico.asitipcod   ,
    asimtvcod         like datkasimtv.asimtvcod    ,
    asimtvdes         like datkasimtv.asimtvdes    ,
    atdhorpvt         like datmservico.atdhorpvt   ,
    atddat            like datmservico.atddat      ,
    atdhor            like datmservico.atdhor      ,
    nom               like datmservico.nom         ,
    ramcod            like datrservapol.ramcod     ,
    ramnom            like gtakram.ramnom     ,
    ramsgl            like gtakram.ramsgl     ,
    succod            like datrservapol.succod     ,
    aplnumdig         like datrservapol.aplnumdig  ,
    itmnumdig         like datrservapol.itmnumdig  ,
    vcldes            like datmservico.vcldes      ,
    vclanomdl         like datmservico.vclanomdl   ,
    vcllicnum         like datmservico.vcllicnum   ,
    vclcorcod         like datmservico.vclcorcod   ,
    dddcod            like gsakend.dddcod          ,
    teltxt            like gsakend.teltxt          ,
    atdrsdflg         like datmservico.atdrsdflg   ,
    atddfttxt         like datmservico.atddfttxt   ,
    roddantxt         like datmservicocmp.roddantxt,
    bocnum            like datmservicocmp.bocnum   ,
    bocemi            like datmservicocmp.bocemi   ,
    rmcacpflg         like datmservicocmp.rmcacpflg,
    srvprlflg         like datmservico.srvprlflg   ,
    atdvclsgl         like datmservico.atdvclsgl   ,
    socvclcod         like datmservico.socvclcod   ,
    atdmotnom         like datmservico.atdmotnom   ,
    srrcoddig         like datmservico.srrcoddig   ,
    srrabvnom         like datksrr.srrabvnom       ,
    traco             char (132)                   ,
    privez            smallint                     ,
    vclcordes         char (20)                    ,
    srvtipabvdes      like datksrvtip.srvtipabvdes ,
    asitipabvdes      like datkasitip.asitipabvdes ,
    atdrsddes         char (03)                    ,
    rmcacpdes         char (03)                    ,
    c24srvdsc         like datmservhist.c24srvdsc  ,
    atddatprg         like datmservico.atddatprg   ,
    atdhorprg         like datmservico.atdhorprg   ,
    pasnom            like datmpassageiro.pasnom   ,
    pasidd            like datmpassageiro.pasidd   ,
    bagflg            like datmassistpassag.bagflg ,
    trppfrdat         like datmassistpassag.trppfrdat,
    trppfrhor         like datmassistpassag.trppfrhor,
    lclrsccod         like datmsrvre.lclrsccod     ,
    orrdat            like datmsrvre.orrdat        ,
    orrhor            like datmsrvre.orrhor        ,
    sinntzcod         like datmsrvre.sinntzcod     ,
    socntzcod         like datmsrvre.socntzcod     ,
    ntzdes            char (40)                    ,
    atddmccidnom      like datmassistpassag.atddmccidnom,
    atddmcufdcod      like datmassistpassag.atddmcufdcod,
    atddstcidnom      like datmassistpassag.atddstcidnom,
    atddstufdcod      like datmassistpassag.atddstufdcod,
    lclrefptotxt1     char (100),
    lclrefptotxt2     char (100),
    sqlcode           integer,
    imsvlr            like abbmcasco.imsvlr,
    imsvlrdes         char (08),
    vclcndlclcod      like datrcndlclsrv.vclcndlclcod,
    vclcndlcldes      like datkvclcndlcl.vclcndlcldes ,
    grupo             like gtakram.ramgrpcod,
    ciaempcod         like datmservico.ciaempcod,
    qtddia            like datmhosped.hpddiapvsqtd,
    qtdqrt            like datmhosped.hpdqrtqtd   ,
    lignum            like datrligsrv.lignum
 end record

 define a_cts00m14    array[2] of record
    lclidttxt         like datmlcl.lclidttxt       ,
    lgdtxt            char (80)                    ,
    lgdtip            like datmlcl.lgdtip          ,
    lgdnom            like datmlcl.lgdnom          ,
    lgdnum            like datmlcl.lgdnum          ,
    brrnom            like datmlcl.brrnom          ,
    lclbrrnom         like datmlcl.lclbrrnom       ,
    endzon            like datmlcl.endzon          ,
    cidnom            like datmlcl.cidnom          ,
    ufdcod            like datmlcl.ufdcod          ,
    lgdcep            like datmlcl.lgdcep          ,
    lgdcepcmp         like datmlcl.lgdcepcmp       ,
    dddcod            like datmlcl.dddcod          ,
    lcltelnum         like datmlcl.lcltelnum       ,
    lclcttnom         like datmlcl.lclcttnom       ,
    lclrefptotxt      like datmlcl.lclrefptotxt    ,
    c24lclpdrcod      like datmlcl.c24lclpdrcod    ,
    endcmp            like datmlcl.endcmp
 end record

 define al_saida array[10] of record
    atdmltsrvnum like datratdmltsrv.atdmltsrvnum
   ,atdmltsrvano like datratdmltsrv.atdmltsrvano
   ,socntzdes    like datksocntz.socntzdes
   ,espdes       like dbskesp.espdes
   ,atddfttxt    like datmservico.atddfttxt
 end record

 define lr_ffpfc073 record
        cgccpfnumdig char(18) ,
        cgccpfnum    char(12) ,
        cgcord       char(4)  ,
        cgccpfdig    char(2)  ,
        mens         char(50) ,
        erro         smallint
 end record

 define l_acihor record
        atddat  like datmsrvacp.atdetpdat ,
        atdhor  like datmsrvacp.atdetphor ,
        acistr  char(70)
 end record

 define lr_retorno record
     pansoclmtqtd  like datkitaasipln.pansoclmtqtd ,
     socqlmqtd     like datkitaasipln.socqlmqtd    ,
     erro          integer,
     mensagem      char(50)
  end record

 define l_resultado smallint,
        l_mensagem  char(30),
        l_doc_handle integer,
        l_cont      smallint,
        l_passou    smallint,
        l_cartao    char(30),
        l_kmazul    char(3),
        l_qtdeazul  char(3),
        l_kmazulint integer

 define arr_aux       smallint
       ,vl_ligcvntip  like datmligacao.ligcvntip

 define l_espdes     like dbskesp.espdes,
        l_docto      char(100),
        l_segnom     like gsakseg.segnom,
        l_crtsaunum  like datrligsau.crtnum

  define l_limpecas char(50),
         l_mobrefvlr like dpakpecrefvlr.mobrefvlr,
         l_pecmaxvlr like dpakpecrefvlr.pecmaxvlr
--varani


 output report to pipe  wsgpipe
   left   margin  00
   right  margin  80
   top    margin  00
   bottom margin  00
   page   length  58

 format
   on every row

        initialize al_saida to null
        initialize lr_ffpfc073.* to null
        let l_resultado = null
        let l_mensagem  = null
        let l_cont      = 1
        let l_limpecas = null
        initialize  a_cts00m14  to null
        initialize  ws.*        to null
        initialize lr_retorno.* to null

        let ws.traco = "------------------------------------------------------------------------------------------------------------------------------------"
        let ws.privez = 0

        # -- OSF 12718 - Fabrica de Software, Katiucia -- #
        declare ccts00m14001 cursor
            for select b.ligcvntip, b.ciaempcod
                  from datrligsrv a, datmligacao b
                 where a.atdsrvnum = r_cts00m14.atdsrvnum
                   and a.atdsrvano = r_cts00m14.atdsrvano
                   and a.lignum    = b.lignum

        open ccts00m14001
           fetch ccts00m14001 into vl_ligcvntip, ws.ciaempcod

           if sqlca.sqlcode = notfound then
              initialize vl_ligcvntip to null
           end if
        close ccts00m14001

        if r_cts00m14.enviar = "F"  then
           if wsgfax = "GSF"  then
              #----------------------------------------
              # Checa caracteres invalidos para o GSFAX
              #----------------------------------------
              call cts02g00(r_cts00m14.nomgrr)  returning r_cts00m14.nomgrr

              if r_cts00m14.dddcod     >  0099  then
                 print column 001, r_cts00m14.dddcod using "&&&&"; #
              else                                                 # Codigo DDD
                 print column 001, r_cts00m14.dddcod using "&&&";  #
              end if

              #--> Numero FAX
              #---------------
              if r_cts00m14.faxnum > 99999999  then
                 print column 001, r_cts00m14.faxnum using "&&&&&&&&&";
              else
                 if r_cts00m14.faxnum > 9999999  then
                    print column 001, r_cts00m14.faxnum using "&&&&&&&&";
                 else
                    if r_cts00m14.faxnum > 999999  then
                       print column 001, r_cts00m14.faxnum using "&&&&&&&";
                    else
                       print column 001, r_cts00m14.faxnum using "&&&&&&";
                    end if
                 end if
              end if

              print column 001                        ,
              "@"                                     ,  #--> Delimitador
              r_cts00m14.nomgrr                       ,  #--> Destinatario Cx pos
              "*CTPS"                                 ,  #--> Sistema/Subsistema
              r_cts00m14.faxch1    using "&&&&&&&&&&" ,  #--> No./Ano Servico
              r_cts00m14.faxch2    using "&&&&&&&&&&" ,  #--> Sequencia
              "@"                                     ,  #--> Delimitador
              r_cts00m14.nomgrr                       ,  #--> Destinat.(Informix)
              "@"                                     ,  #--> Delimitador
              "CENTRAL 24 HORAS"                      ,  #--> Quem esta enviando
              "@"                                     ,  #--> Delimitador
              "132PORTO.TIF"                          ,  #--> Arquivo Logotipo
              "@"                                     ,  #--> Delimitador
              "semcapa"                                  #--> Nao tem cover page
           end if

           if wsgfax = "VSI" then
              case ws.ciaempcod
                when 1
                  print column 001, ascii 27, "&k2S";        #--> Caracteres
                  print             ascii 27, "(s7b";        #--> de controle
                  print             ascii 27, "(s4102T";     #--> para 132
                  print             ascii 27, "&l08D";       #--> colunas
                  print             ascii 27, "&l00E";       #--> Logo no topo
                  print column 001, "@+IMAGE[porto.tif;x=0cm;y=0cm]"
                  skip 8 lines

                when 35
                  print column 001, ascii 27, "&k2S";        #--> Caracteres
                  print             ascii 27, "(s7b";        #--> de controle
                  print             ascii 27, "(s4102T";     #--> para 132
                  print             ascii 27, "&l08D";       #--> colunas
                  print             ascii 27, "&l00E";       #--> Logo no topo
                  print column 001, "@+IMAGE[azul.tif;x=0cm;y=0cm]"
                  skip 7 lines

                when 84
                  print column 001, ascii 27, "&k2S";        #--> Caracteres
                  print             ascii 27, "(s7b";        #--> de controle
                  print             ascii 27, "(s4102T";     #--> para 132
                  print             ascii 27, "&l08D";       #--> colunas
                  print             ascii 27, "&l00E";       #--> Logo no topo
                  print column 001, "@+IMAGE[itau.tif;x=0cm;y=0cm]"
                  skip 7 lines

                otherwise
                  print column 001, ascii 27, "&k2S";        #--> Caracteres
                  print             ascii 27, "(s7b";        #--> de controle
                  print             ascii 27, "(s4102T";     #--> para 132
                  print             ascii 27, "&l08D";       #--> colunas
              end case

           end if
        end if

       #--------------------------------------------------------------
        # Busca informacoes do servico
        #--------------------------------------------------------------
        select datmservico.atdsrvorg   , datmservico.asitipcod   ,
               datmservico.atdhorpvt   , datmservico.atddat      ,
               datmservico.atdhor      , datmservico.nom         ,
               datrservapol.ramcod     , datrservapol.succod     ,
               datrservapol.aplnumdig  , datrservapol.itmnumdig  ,
               datmservico.vcldes      , datmservico.vclanomdl   ,
               datmservico.vcllicnum   , datmservico.vclcorcod   ,
               datmservico.atdrsdflg   , datmservico.atddfttxt   ,
               datmservico.atdvclsgl   , datmservico.atdmotnom   ,
               datmservico.atddatprg   , datmservico.atdhorprg   ,
               datmservico.socvclcod   , datmservico.srvprlflg   ,
               datmservico.srrcoddig   ,
               datmservicocmp.roddantxt, datmservicocmp.bocnum   ,
               datmservicocmp.bocemi   , datmservicocmp.rmcacpflg,
               datmservico.ciaempcod
          into ws.atdsrvorg    , ws.asitipcod    ,
               ws.atdhorpvt    , ws.atddat       ,
               ws.atdhor       , ws.nom          ,
               ws.ramcod       , ws.succod       ,
               ws.aplnumdig    , ws.itmnumdig    ,
               ws.vcldes       , ws.vclanomdl    ,
               ws.vcllicnum    , ws.vclcorcod    ,
               ws.atdrsdflg    , ws.atddfttxt    ,
               ws.atdvclsgl    , ws.atdmotnom    ,
               ws.atddatprg    , ws.atdhorprg    ,
               ws.socvclcod    , ws.srvprlflg    ,
               ws.srrcoddig    ,
               ws.roddantxt    , ws.bocnum       ,
               ws.bocemi       , ws.rmcacpflg    ,
               ws.ciaempcod
          from datmservico, outer datmservicocmp, outer datrservapol
         where datmservico.atdsrvnum    = r_cts00m14.atdsrvnum
           and datmservico.atdsrvano    = r_cts00m14.atdsrvano

           and datmservicocmp.atdsrvnum = datmservico.atdsrvnum
           and datmservicocmp.atdsrvano = datmservico.atdsrvano

           and datrservapol.atdsrvnum   = datmservico.atdsrvnum
           and datrservapol.atdsrvano   = datmservico.atdsrvano

        #--------------------------------------------------------------
        # Busca descricao do ramo
        #--------------------------------------------------------------
        #select ramnom
        #     into ws.ramnom
        #     from gtakram
        #     where ramcod = ws.ramcod
        #       and empcod = 1
        #if sqlca.sqlcode <> 0 then
        #   let ws.ramcod = "N/CADASTR"
        #end if

        ### PSI 202720

   if ws.atdsrvorg  =   2    or
      ws.atdsrvorg  =   3    then  --varani
      select asimtvcod
      into ws.asimtvcod
      from datmassistpassag
      where atdsrvnum = r_cts00m14.atdsrvnum   and
            atdsrvano = r_cts00m14.atdsrvano

      if ws.atdsrvorg =  03  then
         select hpddiapvsqtd
         into ws.qtddia
         from datmhosped
         where atdsrvnum = r_cts00m14.atdsrvnum
         and atdsrvano = r_cts00m14.atdsrvano
      end if
   end if

        ## Obter os servicos multiplos
   call cts29g00_obter_multiplo(1,
                                r_cts00m14.atdsrvnum,
                                r_cts00m14.atdsrvano)
        returning l_resultado
                 ,l_mensagem
                 ,al_saida[1].*
                 ,al_saida[2].*
                 ,al_saida[3].*
                 ,al_saida[4].*
                 ,al_saida[5].*
                 ,al_saida[6].*
                 ,al_saida[7].*
                 ,al_saida[8].*
                 ,al_saida[9].*
                 ,al_saida[10].*

   if l_resultado = 3 then
      error l_mensagem sleep 2
   else
       if (ws.atdsrvorg = 2 or ws.atdsrvorg = 3) then
          call ctr03m02_busca_limite_cob( r_cts00m14.atdsrvnum
                                        ,r_cts00m14.atdsrvano
                                        ,ws.succod
                                        ,ws.aplnumdig  --varani --> passando os parametros recuperados
                                        ,ws.itmnumdig
                                        ,ws.asitipcod
                                        ,ws.ramcod
                                        ,ws.asimtvcod
                                        ,vl_ligcvntip
                                        ,ws.qtddia
                                        ,ws.atdsrvorg  )
              returning m_mensagem_2,
                        m_mensagem_3,
                        m_mensagem_4,
                        m_mensagem_5,
                        m_mensagem_6
       end if

   end if

   call cty10g00_descricao_ramo(ws.ramcod, g_issk.empcod)
             returning l_resultado, l_mensagem, ws.ramnom, ws.ramsgl

   call cty10g00_grupo_ramo(g_issk.empcod, ws.ramcod)
             returning l_resultado, l_mensagem, ws.grupo

        #--------------------------------------------------------------
        # Busca informacoes do local da ocorrencia
        #--------------------------------------------------------------
   call ctx04g00_local_completo(r_cts00m14.atdsrvnum,
                                     r_cts00m14.atdsrvano,
                                     1)
                           returning a_cts00m14[1].lclidttxt   ,
                                     a_cts00m14[1].lgdtip      ,
                                     a_cts00m14[1].lgdnom      ,
                                     a_cts00m14[1].lgdnum      ,
                                     a_cts00m14[1].lclbrrnom   ,
                                     a_cts00m14[1].brrnom      ,
                                     a_cts00m14[1].cidnom      ,
                                     a_cts00m14[1].ufdcod      ,
                                     a_cts00m14[1].lclrefptotxt,
                                     a_cts00m14[1].endzon      ,
                                     a_cts00m14[1].lgdcep      ,
                                     a_cts00m14[1].lgdcepcmp   ,
                                     a_cts00m14[1].dddcod      ,
                                     a_cts00m14[1].lcltelnum   ,
                                     a_cts00m14[1].lclcttnom   ,
                                     a_cts00m14[1].c24lclpdrcod,
                                     ws.sqlcode,
                                     a_cts00m14[1].endcmp

    # PSI 244589 - Inclusão de Sub-Bairro - Burini
    call cts06g10_monta_brr_subbrr(a_cts00m14[1].brrnom,
                                   a_cts00m14[1].lclbrrnom)
         returning a_cts00m14[1].lclbrrnom

    if ws.sqlcode <> 0  then
        error " Erro (", ws.sqlcode, ") na leitura local de ocorrencia.",
                 " AVISE A INFORMATICA!"
#          return
    end if
    let a_cts00m14[1].lgdtxt = a_cts00m14[1].lgdtip clipped, " ",
                               a_cts00m14[1].lgdnom clipped, " ",
                               a_cts00m14[1].lgdnum using "<<<<#", " ",
                               a_cts00m14[1].endcmp clipped

        #--------------------------------------------------------------
        # Busca informacoes do local de destino
        #--------------------------------------------------------------
    call ctx04g00_local_completo(r_cts00m14.atdsrvnum,
                                     r_cts00m14.atdsrvano,
                                     2)
                           returning a_cts00m14[2].lclidttxt   ,
                                     a_cts00m14[2].lgdtip      ,
                                     a_cts00m14[2].lgdnom      ,
                                     a_cts00m14[2].lgdnum      ,
                                     a_cts00m14[2].lclbrrnom   ,
                                     a_cts00m14[2].brrnom      ,
                                     a_cts00m14[2].cidnom      ,
                                     a_cts00m14[2].ufdcod      ,
                                     a_cts00m14[2].lclrefptotxt,
                                     a_cts00m14[2].endzon      ,
                                     a_cts00m14[2].lgdcep      ,
                                     a_cts00m14[2].lgdcepcmp   ,
                                     a_cts00m14[2].dddcod      ,
                                     a_cts00m14[2].lcltelnum   ,
                                     a_cts00m14[2].lclcttnom   ,
                                     a_cts00m14[2].c24lclpdrcod,
                                     ws.sqlcode,
                                     a_cts00m14[2].endcmp

        # PSI 244589 - Inclusão de Sub-Bairro - Burini
        call cts06g10_monta_brr_subbrr(a_cts00m14[2].brrnom,
                                       a_cts00m14[2].lclbrrnom)
             returning a_cts00m14[2].lclbrrnom

        if ws.sqlcode = notfound   then
        else
           if ws.sqlcode = 0   then
              let a_cts00m14[2].lgdtxt = a_cts00m14[2].lgdtip clipped, " ",
                                         a_cts00m14[2].lgdnom clipped, " ",
                                         a_cts00m14[2].lgdnum using "<<<<#", " ",
                                         a_cts00m14[2].endcmp clipped
           else
              error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura",
                    " local de destino. AVISE A INFORMATICA!"
#             return
           end if
        end if

        ### PSI 202720
        if ws.grupo = 5 then ## Saude
           call cts20g10_cartao(1, r_cts00m14.atdsrvnum, r_cts00m14.atdsrvano)
                returning l_resultado, l_mensagem, l_crtsaunum

           call cta01m15_sel_datksegsau (3, l_crtsaunum, "","")
                returning l_resultado, l_mensagem, l_segnom,
                          ws.dddcod, ws.teltxt

        else
           case ws.ciaempcod
              when 1
                 call cts09g00(ws.ramcod, ws.succod, ws.aplnumdig,
                               ws.itmnumdig,false)
                      returning ws.dddcod, ws.teltxt
              when 35
                 if ws.aplnumdig is not null then
                    call cts42g00_doc_handle(ws.succod, ws.ramcod,
                                             ws.aplnumdig, ws.itmnumdig,
                                             g_documento.edsnumref)
                         returning l_resultado, l_mensagem, l_doc_handle

                    call cts40g02_extraiDoXML(l_doc_handle, "FONE_SEGURADO")
                         returning ws.dddcod, ws.teltxt

                    ---> Busca Limites da Azul
                    call cts49g00_clausulas(l_doc_handle)
                         returning l_kmazul, l_qtdeazul

                 end if

              when 40
                    #---------------------------------------------------------------
                    # Dados da ligacao
                    #---------------------------------------------------------------
                    let ws.lignum = cts20g00_servico(r_cts00m14.atdsrvnum, r_cts00m14.atdsrvano)


                    whenever error continue
                    select cgccpfnum,
                           cgcord    ,
                           cgccpfdig
                      into lr_ffpfc073.cgccpfnum,
                           lr_ffpfc073.cgcord   ,
                           lr_ffpfc073.cgccpfdig
                      from datrligcgccpf
                     where lignum = ws.lignum
                    whenever error stop

                    let lr_ffpfc073.cgccpfnumdig = ffpfc073_formata_cgccpf(lr_ffpfc073.cgccpfnum ,
                                                                           lr_ffpfc073.cgcord    ,
                                                                           lr_ffpfc073.cgccpfdig )

                       call ffpfc073_rec_tel(lr_ffpfc073.cgccpfnumdig,'F')
                             returning ws.dddcod         ,
                                       ws.teltxt         ,
                                       lr_ffpfc073.mens  ,
                                       lr_ffpfc073.erro

                       if lr_ffpfc073.erro <> 0 then
                           error lr_ffpfc073.mens
                       end if

              when 84
              if g_documento.ramcod = 531 or g_documento.ramcod = 31 then
                 call cty22g00_rec_dados_itau(g_documento.itaciacod,
	       		               g_documento.ramcod   ,
	       		               g_documento.aplnumdig,
	       		               g_documento.edsnumref,
	       		               g_documento.itmnumdig)
	              returning lr_retorno.erro,
	                        lr_retorno.mensagem

	                if lr_retorno.erro = 0 then
	                  let ws.dddcod = g_doc_itau[1].segresteldddnum
	                  let ws.teltxt = g_doc_itau[1].segrestelnum
	               else
	                  let ws.dddcod = 0
	                  let ws.teltxt = 0
	               end if
	            else
	               call cty25g01_rec_dados_itau (g_documento.itaciacod,
	                                         g_documento.ramcod   ,
	                                         g_documento.aplnumdig,
	                                         g_documento.edsnumref,
	                                         g_documento.itmnumdig)

	                returning lr_retorno.erro,
	                          lr_retorno.mensagem
	                if lr_retorno.erro = 0 then

	                  let ws.dddcod = g_doc_itau[1].segresteldddnum
	                  let ws.teltxt = g_doc_itau[1].segrestelnum
	               else
	                  let ws.dddcod = 0
	                  let ws.teltxt = 0
	               end if
	            end if
	   end case
        end if

        #--------------------------------------------------------------
        # Verifica se veiculo e BLINDADO.
        #--------------------------------------------------------------
        call f_funapol_ultima_situacao
             (ws.succod, ws.aplnumdig, ws.itmnumdig) returning g_funapol.*
        let ws.imsvlr = 0
        select imsvlr
             into ws.imsvlr
             from abbmbli
            where succod    = g_documento.succod    and
                  aplnumdig = g_documento.aplnumdig and
                  itmnumdig = g_documento.itmnumdig and
                  dctnumseq = g_funapol.autsitatu

        #--------------------------------------------------------------
        # Busca natureza Porto Socorro/Sinistro de R.E.
        #--------------------------------------------------------------
        if ws.atdsrvorg = 9    or
           ws.atdsrvorg = 13   then
           select lclrsccod, orrdat   ,
                  orrhor   , sinntzcod,
                  socntzcod
             into ws.lclrsccod        ,
                  ws.orrdat           ,
                  ws.orrhor           ,
                  ws.sinntzcod        ,
                  ws.socntzcod
             from datmsrvre
            where atdsrvnum = r_cts00m14.atdsrvnum  and
                  atdsrvano = r_cts00m14.atdsrvano

           let ws.ntzdes = "*** NAO CADASTRADO ***"

           if ws.sinntzcod is not null  then
              select sinntzdes
                into ws.ntzdes
                from sgaknatur
               where sinramgrp = "4"      and
                     sinntzcod = ws.sinntzcod
           else
              select socntzdes
                into ws.ntzdes
                from datksocntz
               where socntzcod = ws.socntzcod
           end if
        end if

        let ws.srvtipabvdes = "NAO CADASTR"

        select srvtipabvdes
          into ws.srvtipabvdes
          from datksrvtip
         where atdsrvorg = ws.atdsrvorg

        let ws.asitipabvdes = "N/CADAST"

        select asitipabvdes
          into ws.asitipabvdes
          from datkasitip
         where asitipcod = ws.asitipcod

        case ws.atdrsdflg
           when "S"  let ws.atdrsddes = "SIM"
           when "N"  let ws.atdrsddes = "NAO"
        end case

        case ws.rmcacpflg
           when "S"  let ws.rmcacpdes = "SIM"
           when "N"  let ws.rmcacpdes = "NAO"
        end case

        if ws.vclcorcod   is not null    then
           select cpodes
             into ws.vclcordes
             from iddkdominio
            where cponom = "vclcorcod"    and
                  cpocod = ws.vclcorcod
        end if

        if r_cts00m14.enviar  =  "I"   then
           print column 001, "Enviar para: ", r_cts00m14.nomgrr,
             "    Fax: ", "(",r_cts00m14.dddcod, ")", r_cts00m14.faxnum
        end if

        skip 1 line

        print column 001,
     "*** EM CASO DE DUVIDA, ENTRAR EM CONTATO PELO TELEFONE DE APOIO (011)3366-3055 ***"
        skip 1 line

        if ws.ciaempcod <> 35 and ws.ciaempcod <> 84 then
            if m_mensagem_2 is not null then
                skip 1 line
                print column 001, m_mensagem_2 clipped
                print column 001, m_mensagem_3 clipped, m_mensagem_4 clipped
                print column 001, m_mensagem_5 clipped
                print column 001, m_mensagem_6 clipped
                skip 1 line
            end if
        end if

        #TROCA DE FONTE
        ##print ascii(27),"(s0p17h0s3b40999T"

        if ws.ciaempcod = 35 then  ## psi 205206
           print column 001,
    "+----------------------------  *** AZUL SEGUROS ***  --------------------------------+"
           print column 001,
    "|Em caso de viagem, devidamente autorizada pela central de atendimento, COBRAR       |"

           let l_kmazulint = l_kmazul
           let l_kmazulint = l_kmazulint * 2

           print column 001,
    "|** ATE ", l_kmazulint using "<<<#", "KM DA AZUL SEGUROS **, qualquer KM excedente deve ser cobrado do segurado.|"
           print column 001,
    "+------------------------------------------------------------------------------------+"
           skip 1 line
        end if

        if ws.ciaempcod = 84 and ws.atdsrvorg <> 2 and ws.atdsrvorg <> 3 then

           if g_documento.ramcod = 531 or g_documento.ramcod = 31 then
                      call cty22g00_rec_plano_assistencia(g_doc_itau[1].itaasiplncod)
                           returning lr_retorno.pansoclmtqtd ,
                                     lr_retorno.socqlmqtd    ,
                                     lr_retorno.erro         ,
                                     lr_retorno.mensagem

                      let l_kmazulint = lr_retorno.socqlmqtd
                      let l_kmazulint = l_kmazulint * 2


                      print column 001,
               "+---------------------------------  *** ITAÚ AUTO E RESIDÊNCIA  ***  ---------------------------------+"
                      print column 001,
               "|Em caso de viagem, devidamente autorizada pela central de atendimento, COBRAR ** ATE ",l_kmazulint using "<<<#"," KM DA   |"


                      print column 001,
               "| Itaú Auto e Residência  **, qualquer KM excedente deve ser cobrado do segurado.                     |"
                      print column 001,
               "+-----------------------------------------------------------------------------------------------------+"
                      skip 1 line
           else

             select socntzcod
               into ws.socntzcod
               from datmsrvre
              where atdsrvnum = r_cts00m14.atdsrvnum
                and atdsrvano = r_cts00m14.atdsrvano

             select mobrefvlr,
                    pecmaxvlr
               into l_mobrefvlr,
                    l_pecmaxvlr
               from dpakpecrefvlr
              where socntzcod = ws.socntzcod
                and empcod    = ws.ciaempcod

	          if (l_mobrefvlr is not null or l_mobrefvlr <> '') and
               (l_pecmaxvlr is not null or l_pecmaxvlr <> '') then

                 print column 001,
               "+---------------------------------  *** ITAÚ AUTO E RESIDÊNCIA  ***  ---------------------------------+"
                      print column 001,
               "|Em caso de fornecimento de pecas, COBRAR ** ATE ",l_pecmaxvlr using "&&&&&&&.&&"," Itaú Auto e Residência  **.   |"


                      print column 001,
               "| Em caso de excedente entrar em contato com a cental de atendimento.                                 |"
                      print column 001,
               "+-----------------------------------------------------------------------------------------------------+"
                      skip 1 line
              end if
           end if
        else
           if ws.atdsrvorg = 3 and ws.ciaempcod = 84 then
                 let l_kmazulint = 200.00
                 print column 001,
       "+---------------------------------  *** ITAÚ AUTO E RESIDÊNCIA  ***  --------------------------------+"
              print column 001,
       "|Em caso de hospedagem, devidamente autorizada pela central de atendimento, COBRAR ** ATE R$:",l_kmazulint using "<<<#"," DA   |"


              print column 001,
       "|Itaú Auto e Residência  **, qualquer valor excedente deve ser cobrado do segurado.                      |"
              print column 001,
       "+-----------------------------------------------------------------------------------------------------+"
              skip 1 line
           end if
        end if

        if ws.atddatprg  is not null   then
           if ws.atddatprg = today     or
              ws.atddatprg > today     then
              print column 001, "*** SERVICO PROGRAMADO PARA: ", ws.atddatprg, " AS ", ws.atdhorprg, " ***"
           end if
        end if

        initialize l_acihor.* to null

        whenever error continue
        select atdetpdat, atdetphor into l_acihor.atddat, l_acihor.atdhor
        from datmsrvacp
        where atdsrvnum = r_cts00m14.atdsrvnum
          and atdsrvano = r_cts00m14.atdsrvano
          and atdsrvseq = ( select max(atdsrvseq)
                            from datmsrvacp
                            where atdsrvnum = r_cts00m14.atdsrvnum
                              and atdsrvano = r_cts00m14.atdsrvano
                              and atdetpcod in (4,3,10) )
        whenever error stop

        if l_acihor.atddat is not null and
           l_acihor.atdhor is not null then

           let l_acihor.acistr = "Acionado em: ", l_acihor.atddat, " as ",
                                 l_acihor.atdhor
        else
           let l_acihor.acistr = "Solicitado em: ", ws.atddat, " as ", ws.atdhor
        end if

        print column 001, ws.traco
        print column 001, "Tipo Servico.: "     , ws.srvtipabvdes,
              column 027, "Tipo Socorro: "      , ws.asitipabvdes,
              column 046, "Previsao: "          , ws.atdhorpvt,
              column 076, l_acihor.acistr clipped

        print column 001, "Ordem Servico: "     ,
                          ws.atdsrvorg         using "&&"      , "/",
                          r_cts00m14.atdsrvnum using "&&&&&&&" , "-",
                          r_cts00m14.atdsrvano using "&&",
              column 031, "Nat: ", ws.ntzdes,
              column 076, "Problema: ", ws.atddfttxt

        let l_espdes = null

        select espcod
          into l_espdes
          from datmsrvre
         where atdsrvnum = r_cts00m14.atdsrvnum
           and atdsrvano = r_cts00m14.atdsrvano


        # --SE O SERVICO POSSUIR A DESCRICAO DA ESPECIALIDADE, ENTAO EXIBE
        if l_espdes is not null and
           l_espdes <> " " then
           print column 031, "Esp: ", l_espdes
        end if

        for l_cont = 1 to 10
            if al_saida[l_cont].atdmltsrvnum is not null and
               al_saida[l_cont].atdmltsrvano is not null then
               print column 016,ws.atdsrvorg using '&&','/',
                                al_saida[l_cont].atdmltsrvnum using '&&&&&&&','-',
                                al_saida[l_cont].atdmltsrvano using '&&',
                     column 031, 'Nat: ',al_saida[l_cont].socntzdes,
                     column 076, 'Problema: ',al_saida[l_cont].atddfttxt

               let l_espdes = null

               # --BUSCA A DESCRICAO DA ESPECIALIDADE DO SERVICO
               let l_espdes = cts00m14_busca_especialidade(al_saida[l_cont].atdmltsrvnum,
                                                           al_saida[l_cont].atdmltsrvano)

               # --SE O SERVICO POSSUIR A DESCRICAO DA ESPECIALIDADE, ENTAO EXIBE
               if l_espdes is not null and
                  l_espdes <> " " then
                  print column 031, "Esp: ", l_espdes
               end if

            end if
        end for

        #-----------------------------------------------------------
        # Se codigo veiculo informado, ler cadastro de veiculos
        #-----------------------------------------------------------
        if ws.socvclcod  is not null   then
           select atdvclsgl
             into ws.atdvclsgl
             from datkveiculo
            where datkveiculo.socvclcod  =  ws.socvclcod
        end if

        #-----------------------------------------------------------
        # Se codigo socorrista informado, ler cadastro de socorrista
        #-----------------------------------------------------------
        if ws.srrcoddig  is not null   then
           select srrabvnom
             into ws.srrabvnom
             from datksrr
            where datksrr.srrcoddig  =  ws.srrcoddig
        end if

        if ws.atdvclsgl  is not null   or
           ws.atdmotnom  is not null   or
           ws.srrabvnom  is not null   then
           if ws.atdmotnom  is not null   and
              ws.atdmotnom  <>  "  "      then
              print column 001, "Viatura......: "  , ws.atdvclsgl,
                    column 027, "Socorrista...: "  , ws.atdmotnom
           else
              print column 001, "Viatura......: "  , ws.atdvclsgl,
                    column 027, "Socorrista...: "  ,
                           ws.srrcoddig using "####&&&&", " - ", ws.srrabvnom
           end if
        end if

        print column 001, ws.traco
        if ws.atdsrvorg = 9    or
           ws.atdsrvorg = 13   then

           ### PSI 202720
           if ws.grupo = 5 then ## Saude
              let l_cartao = null
              call cts20g16_formata_cartao(l_crtsaunum)
                   returning l_cartao
              let l_docto = "Cartao Saude : ", l_cartao
           else
              let l_docto = "Ramo/Suc/Apol: ",
                             ws.ramcod    using "&&&&"      , " ",
                             ws.succod    using "&&&&&"     , " ", #"&&&&"      , " ", #projeto succod
                             ws.aplnumdig using "&&&&&&&& &", " "
           end if

           print column 001, "Segurado.....: ", ws.nom,
                 column 061, l_docto,

                 #column 061, "Ramo/Suc/Apol: "            ,
                 #            ws.ramcod    using "&&&&"      , " ",
                 #            ws.succod    using "&&&&"      , " ",
                 #            ws.aplnumdig using "&&&&&&&& &", " ",

                 column 100, "Telef.: "                          ,
                             "(", ws.dddcod ,") ",ws.teltxt[1,16]
        else
           print column 001, "Ramo.........: ", ws.ramcod,"  ",ws.ramnom
        end if
        print column 001, "Responsavel..: "  , a_cts00m14[1].lclcttnom,
              column 061, "Telef. Local.: (",a_cts00m14[1].dddcod ,") ",
                          a_cts00m14[1].lcltelnum;
        if ws.atdrsddes is null  then
           print column 112, " "
        else
           print column 112, "Residencia: "  , ws.atdrsddes
        end if

        if ws.atdsrvorg = 9    or
           ws.atdsrvorg = 13   then
        #  Livre
        else
           initialize ws.imsvlrdes to null
           if ws.imsvlr > 0 then
              let ws.imsvlrdes = "BLINDADO"
           end if
           print column 001, "Veiculo......: "     , ws.vcldes   ,
                 column 061, "Ano: "               , ws.vclanomdl,
                 column 081, "Placa: "             , ws.vcllicnum,
                 column 097, "Cor...: "            , ws.vclcordes,
                 column 124, ws.imsvlrdes
        end if

       #skip 1 line

        #-----------------------------------------------------------------
        # Exibe endereco do local da ocorrencia
        #-----------------------------------------------------------------
        initialize ws.lclrefptotxt1, ws.lclrefptotxt2 to null
        let ws.lclrefptotxt1 = a_cts00m14[1].lclrefptotxt[001,100]
        let ws.lclrefptotxt2 = a_cts00m14[1].lclrefptotxt[101,200]

        if a_cts00m14[1].lclidttxt  is not null   then
           print column 001, "Local........: "  , a_cts00m14[1].lclidttxt
        end if

        print column 001, "Endereco.....: ", a_cts00m14[1].lgdtxt   ,
              column 081, "Bairro.....: "  , a_cts00m14[1].lclbrrnom
        print column 001, "Cidade.......: ", a_cts00m14[1].cidnom
                          clipped, " - "   , a_cts00m14[1].ufdcod

        if ws.lclrefptotxt1 is not null then
           print column 001, "Referencia...: ", ws.lclrefptotxt1
        end if
        if ws.lclrefptotxt2 is not null then
           print column 001, "               ", ws.lclrefptotxt2
        end if

        if ws.atdsrvorg  =   4     or
           ws.atdsrvorg  =   6     or
           ws.atdsrvorg  =   1     then
           print column 001, "Rodas Danific: ", ws.roddantxt,
                 column 061, "B.O........: "  , ws.bocnum using  "<<<<#", "  ", ws.bocemi
        else
           if ws.atdsrvorg =  5   or
              ws.atdsrvorg =  7   or   # Replace - RPT
              ws.atdsrvorg = 17   then # Replace sem docto
              if ws.roddantxt is not null  then
                 print column 001, "Rodas Danific: " , ws.roddantxt
              end if
           else
              if ws.atdsrvorg =  9   or
                 ws.atdsrvorg = 13   then
                 skip 1 line
                 print column 001, "Data Ocorr...: "     , ws.orrdat   ,
                       column 061, "Hora Ocorr: "        , ws.orrhor
              end if
           end if
        end if

        skip 1 line

        #-----------------------------------------------------
        # PARA REMOCAO, DAF, SOCORRO, RPT, REPLACE  (DESTINO)
        #-----------------------------------------------------
        if ws.atdsrvorg  =   4    or
           ws.atdsrvorg  =   6    or
           ws.atdsrvorg  =   1    or
           ws.atdsrvorg  =   5    or
           ws.atdsrvorg  =   7    or
           ws.atdsrvorg  =  17    then
           print column 001, "Local Destino: ", a_cts00m14[2].lclidttxt
           print column 001, "Endereco.....: ", a_cts00m14[2].lgdtxt,
                 column 081, "Bairro.....: "  , a_cts00m14[2].lclbrrnom
           print column 001, "Cidade.......: ", a_cts00m14[2].cidnom
                             clipped, " - "   , a_cts00m14[2].ufdcod

           if ws.rmcacpdes is not null  then
              print column 001, "Acompanha Remocao: " , ws.rmcacpdes
           end if
           skip 1 line
        end if

        #------------------------------------------------
        # PARA ASSISTENCIA PASSAGEIROS - TAXI  (DESTINO)
        #------------------------------------------------
        if ws.atdsrvorg  =   2    or
           ws.atdsrvorg  =   3    then
           select atddmccidnom, atddmcufdcod,
                  atddstcidnom, atddstufdcod,
                  asimtvcod   , bagflg      ,
                  trppfrdat   , trppfrhor
             into ws.atddmccidnom,
                  ws.atddmcufdcod,
                  ws.atddstcidnom,
                  ws.atddstufdcod,
                  ws.asimtvcod   ,
                  ws.bagflg      ,
                  ws.trppfrdat   ,
                  ws.trppfrhor
             from datmassistpassag
            where atdsrvnum = r_cts00m14.atdsrvnum   and
                  atdsrvano = r_cts00m14.atdsrvano

           if ws.atdsrvorg    =  2 and
              ws.asitipcod    = 10 then
              print column 001, "Pref. Viagem.: ",
                    column 016, "Data: ", ws.trppfrdat,
                    column 035, "Hora: ", ws.trppfrhor
           end if
           let ws.asimtvdes = "NAO CADASTRADO"

           select asimtvdes
             into ws.asimtvdes
             from datkasimtv
            where asimtvcod = ws.asimtvcod

           # PSI 227145 - retirado
           if (ws.atdsrvorg =  2 and ws.asitipcod = 10) or
               (ws.atdsrvorg = 3 and ws.asitipcod = 13) then
             print column 001, "Domicilio....: "  , ws.atddmccidnom clipped,
                                           " - "  , ws.atddmcufdcod
             print column 001, "Ocorrencia...: "  , a_cts00m14[1].cidnom clipped,
                                           " - "  , a_cts00m14[1].ufdcod
             print column 001, "Destino......: "  , ws.atddstcidnom clipped,
                                           " - "  , ws.atddstufdcod
           end if

           if (ws.atdsrvorg    =  3 )  or
              (ws.atdsrvorg    =  2    and
               ws.asitipcod = 10 )  then
           else
              print column 001, "Local Destino: "  , a_cts00m14[2].lgdtxt,
                    column 076, "Bairro: "         , a_cts00m14[2].lclbrrnom
              print column 001, "Cidade.......: "  , a_cts00m14[2].cidnom
                                clipped, " - "     , a_cts00m14[2].ufdcod
           end if

           if ws.bagflg  =  "S"   then
              print column 001, "Bagagem......: ", "SIM";
           else
              print column 001, "Bagagem......: ", "NAO";
           end if

           print column 061, "Motivo.....: ", ws.asimtvdes
           skip 1 line

           #----------------------------------------------
           # IMPRIME INFORMACOES SOBRE OS PASSAGEIROS
           #----------------------------------------------
           print column 001, "_________________________________________________ Informacoes sobre os Passageiros _________________________________________________"
           declare ccts00m14003  cursor for
              select pasnom, pasidd
                from datmpassageiro
               where atdsrvnum = r_cts00m14.atdsrvnum  and
                     atdsrvano = r_cts00m14.atdsrvano

           foreach ccts00m14003  into  ws.pasnom, ws.pasidd
              print column 026, ws.pasnom,
                    column 075, ws.pasidd, "  anos de idade"
           end foreach
        end if

       let l_passou = false
       declare ccts00m14006 cursor for
       select vclcndlclcod
         from datrcndlclsrv
        where atdsrvnum = r_cts00m14.atdsrvnum
          and atdsrvano = r_cts00m14.atdsrvano

       foreach ccts00m14006 into ws.vclcndlclcod

               if l_passou = false then
                  let l_passou = true
                  print column 001,"LOCAL/CONDICOES DO VEICULO"
               end if

               call ctc61m03 (1,ws.vclcndlclcod) returning ws.vclcndlcldes

               print column 007, ws.vclcndlcldes clipped

       end foreach

       if l_passou = true then
          skip 1 line
       end if

        if ws.atdsrvorg =  9   or
           ws.atdsrvorg = 13   then
           #----------------------------------------------
           # IMPRIME 5 PRIMEIRAS LINHAS DO HISTORICO
           #----------------------------------------------
           declare ccts00m14004  cursor for
              select c24srvdsc
                from datmservhist
               where atdsrvnum = r_cts00m14.atdsrvnum  and
                     atdsrvano = r_cts00m14.atdsrvano

           foreach ccts00m14004  into  ws.c24srvdsc
              if ws.privez  = 0   then
                 print column 001, "_______________________________________________________ Outras Informacoes _________________________________________________________"
              end if
              print column 030, ws.c24srvdsc
              let ws.privez = ws.privez + 1
              if ws.privez > 4   then
                 exit foreach
              end if
           end foreach

           if ws.privez > 0   then
              skip 1 line
           end if
        end if

        #--------------------------------------------------
        # PARA ASSISTENCIA PASSAGEIRO - TAXI  (ASSINATURA)
        #--------------------------------------------------
        if ws.atdsrvorg =  2   and
           ws.asitipcod =  5   then
           skip 1 line
           print column 001, "____________________________________________________________________________________________________________________________________"
           print column 025, "DECLARO TER UTILIZADO O SERVICO DE REMOCAO DE PASSAGEIROS NO TRAJETO ACIMA DESCRITO"
           skip 2 line

           print column 001, "         _________________________        ____________________________            ________________________________________                 "
           print column 001, "                   R. G.                            DATA/HORA                              ASSINATURA DO SEGURADO                          "
           skip 2 lines
        end if

        #-----------------------------------------------------------------
        # PARA REMOCAO, DAF, SOCORRO, RPT, REPLACE  (VISTORIA/ASSINATURA)
        #-----------------------------------------------------------------
        if ws.atdsrvorg  =   4    or
           ws.atdsrvorg  =   6    or
           ws.atdsrvorg  =   1    or
           ws.atdsrvorg  =   5    or
           ws.atdsrvorg  =   7    or
           ws.atdsrvorg  =  17    then

           print column 001, "AVARIAS/DANOS: "
           skip 1 line

           print column 001, "____________________________ Acessorios e Ferramentas Existentes no Veiculo _____________________________   _______ Estado _________"

           print column 001, "Bancos Dian.: S  N"      ,
                 column 023, "Console.....: S  N"      ,
                 column 046, "Rodas Espec.: S  N"      ,
                 column 067, "Bagageiro...: S  N"      ,
                 column 088, "Triangulo..: S  N"       ,
                 column 109, "Pneus Dian.: N/T B  R  P"

           print column 001, "Bancos Tras.: S  N"      ,
                 column 023, "Tapetes.....: S  N"      ,
                 column 046, "Farois......: S  N"      ,
                 column 067, "Obj. P-Malas: S  N"      ,
                 column 088, "Ferramentas: S  N"       ,
                 column 109, "Pneus Tras.: N/T B  R  P"

           print column 001, "Chaves Veic.: S  N"      ,
                 column 023, "Obj. P-Luvas: S  N"      ,
                 column 046, "F. de Milha.: S  N"      ,
                 column 067, "Estepe......: S  N"      ,
                 column 109, "Estepe.....: N/T B  R  P"

           print column 001, "Extintor....: S  N"      ,
                 column 023, "Ant Eletrica: S  N"      ,
                 column 046, "Lanternas...: S  N"      ,
                 column 067, "Macaco......: S  N"      ,
                 column 109, "Banco Dian.: N/T B  R  P"


           print column 109, "Banco Tras.: N/T B  R  P"

           print column 001, "Combustivel..: 4/4 3/4 1/2 1/4  Res.",
                 column 046, "Toca Fitas..: S  N"      ,
                 column 067, "Marca:"                  ,
                 column 088, "Radio......: S  N"       ,
                 column 109, "Marca:"

           print column 001, "Quilometragem:"
           skip 1 line

           print column 001, "____________________________________________________________________________________________________________________________________"

           print column 008, "DECLARO ESTAR DE ACORDO COM AS INFORMACOES PREENCHIDAS NESTE FORMULARIO, BEM COMO COM O DESTINO DO MEU VEICULO."
           skip 1 line

           print column 008, "DECLARO TER RETIRADO DO INTERIOR DO VEICULO TODOS OS BENS E VALORES PESSOAIS NAO INTEGRADOS AO AUTOMOVEL. "

           if ws.ciaempcod is null or ws.ciaempcod = 1 then  ## psi 205206
              print column 008, "FICA A  PORTO SEGURO  ISENTA DE QUALQUER RESPONSABILIDADE SOBRE OS MESMOS."
           else
              if ws.ciaempcod = 35 then
                 print column 008, "FICA A  AZUL SEGUROS  ISENTA DE QUALQUER RESPONSABILIDADE SOBRE OS MESMOS."
              else
                 if ws.ciaempcod = 84 then
                    print column 008, "FICA A  ITAÚ AUTO E RESIDÊNCIA  ISENTA DE QUALQUER RESPONSABILIDADE SOBRE OS MESMOS."
                 end if
              end if
           end if

           skip 1 line

           print column 017, "(SENHOR CLIENTE, EM CASO DE REMOCAO DO VEICULO, SOMENTE ASSINAR COM A PARTE SUPERIOR PREENCHIDA)"
           skip 2 line

           print column 001, "         _________________________        ____________________________            ________________________________________                 "
           print column 001, "                   R. G.                            DATA/HORA                            ASSINATURA DO RESPONSAVEL                       "
           skip 2 line

           print column 001, "____________________________________________________________________________________________________________________________________"

           print column 027, "DECLARO TER RECEBIDO O VEICULO DESCRITO E ESTAR CIENTE DAS ANOTACOES ACIMA"
           skip 2 lines

           print column 001, "         _________________________        ____________________________            ________________________________________                 "
           print column 001, "                   R. G.                            DATA/HORA                                   ASSINATURA                                 "
           skip 2 lines
        end if

        #------------------------------------------------------------------
        # SINISTRO/PORTO SOCORRO (RAMOS ELEMENTARES)
        #------------------------------------------------------------------
        if ws.atdsrvorg  =   9   or
           ws.atdsrvorg  =   13  then
           print column 001, "___________________________________________________ Servicos Realizados ____________________________________________________________"
           skip 1 line
           print column 001, "...................................................................................................................................."
           skip 1 line
           print column 001, "...................................................................................................................................."
           skip 1 line
           print column 001, "...................................................................................................................................."
           skip 1 line
           print column 001, "...................................................................................................................................."
           skip 1 line
           print column 001, "...................................................................................................................................."
           skip 1 line
           print column 001, "...................................................................................................................................."
           skip 1 line
           print column 001, "____________________________________________________________________________________________________________________________________"

           print column 003, "DECLARO ESTAR DE ACORDO COM AS INFORMACOES PREENCHIDAS NESTE FORMULARIO, BEM COMO COM OS SERVICOS REALIZADOS DISCRIMINADOS ACIMA."
           skip 1 line

           print column 032, "(SENHOR CLIENTE, SOMENTE ASSINAR COM A PARTE SUPERIOR PREENCHIDA)"
           skip 2 line

           print column 001, "         _________________________        ____________________________            ________________________________________                 "
           print column 001, "                   R. G.                            DATA/HORA                            ASSINATURA DO RESPONSAVEL                       "
           skip 2 line

        end if

        #------------------------------------------------------------------
        # ULTIMA LINHA (GENERICA)
        #------------------------------------------------------------------
        print column 001, "______________________________________________ Para uso exclusivo do Porto Socorro _________________________________________________"

        skip 1 line

        if ws.srvprlflg = "N"  then
           if ws.atdsrvorg =  9   or
              ws.atdsrvorg = 13   then
           else
              print column 001, "TOTAL DE QUILOMETROS PERCORRIDOS....: "
              skip 1 line
           end if

#          print column 001, "SERAO AGILIZADOS OS PAGAMENTOS CUJAS NOT";
#          print             "AS FISCAIS SEJAM ENCAMINHADAS JUNTAMENTE";
#          print             " COM ESTE IMPRESSO TOTALMENTE PREENCHIDO"
        else
           print column 001, "SERVICO PARTICULAR: PAGAMENTO POR CONTA ";
           print             "DO CLIENTE."
        end if

        skip 1 line

        if ws.atdsrvorg =  9   or
           ws.atdsrvorg = 13   then
           #  Residencia nao imprime mensagens
        else
           print column 001, "_____________________________________________________ Informacoes Importantes ______________________________________________________ "
           skip 1 line

           print column 001, "- IMPORTANTE: O PAGAMENTO A PRESTADORES PESSOA ",
                             "FISICA SOMENTE SERAO EFETUADOS COM A ",
                             "INFORMACAO DO NUMERO DO PIS/PASEP OU INSS NO"
           print column 001, "              CORPO DO DOCUMENTO, PERTENCENTE ",
                             "AO EMISSOR DAS NOTAS FISCAIS OU RECIBOS."
            case ws.ciaempcod

              when 35
              print column 001,
   "- Este serviços será prestado a um segurado da Azul Seguros, com pagamento garantido pela Porto Seguro;"
              print column 001,
   "- Serviços como este, da Azul Seguros, devem ser fechados/acertados separadamente dos serviços da Porto Seguro;"
              print column 001,
   "- Serão geradas automaticamente ordens de pagamento diferentes para Porto e para a Azul Seguros;"
              print column 001,
   "- *** ATENÇÃO *** As notas fiscais de serviços da Azul Seguros devem ser separadas das notas fiscais de serviços da Porto Seguro;"
              skip 1 line
              print column 001,
   "+--Dados da Azul Seguros para emissão da nota fiscal-----------------------------------+"
              print column 001,
   "|Razão Social: Azul Cia. de Seguros Gerais           CNPJ: 33.448.150/0002-00|"
              print column 001,
   "|Endereço: Av Paulista, 453 - 16º andar - Bairro: Centro - São Paulo/SP - CEP 01311-907|"
              print column 001,
   "|Inscrição Municipal: 11.73.29.0-3 (se houver campo na nota fiscal)                    |"
              print column 001,
   "|Inscrição Estadual: Deixar em branco ou Isento (se houver campo na nota fiscal)       |"
              print column 001,
   "+--------------------------------------------------------------------------------------+"
              skip 1 line
              print column 001,
   "- As notas fiscais da Azul Seguros devem ser entregues/enviadas ao Porto Socorro (mesmo local que você já envia as NF da Porto Seguro)."
              print column 001,
   "- Em caso de dúvidas sobre a operação: (11) 3366-5571/72 ou porto.socorro@portoseguro.com.br."
              print column 001,
   "- Em caso de dúvidas sobre pagamento: (11) 3366-6068 ou porto.socorro@portoseguro.com.br."
              print column 001,
   "OBS: Se forem cobrados serviços da Porto Seguro e da Azul Seguros na mesma nota fiscal, a área pagadora devolverá a nota."

              when 84
              print column 001,
   "- Este serviços será prestado a um segurado da Itaú Auto e Residência , com pagamento garantido pela Porto Seguro;"
              print column 001,
   "- Serviços como este, da Itaú Auto e Residência , devem ser fechados/acertados separadamente dos serviços da Porto Seguro;"
              print column 001,
   "- Serão geradas automaticamente ordens de pagamento diferentes para Porto e para a Itaú Auto e Residência ;"
              print column 001,
   "- *** ATENÇÃO *** As notas fiscais de serviços da Itaú Auto e Residência  devem ser separadas das notas fiscais de "
              print column 010,
          "serviços da Porto Seguro;"
              skip 1 line
              print column 001,
   "+--------------Dados da Itaú Auto e Residência  para emissão da nota fiscal--------------+"
              print column 001,
   "|Razão Social: Itaú Seguros de Auto e Residência S.A.      CNPJ: 08.816.067/0001-00|"
              print column 001,
   "|Endereço: Av. Eusébio Matoso,  1375  - Bairro: Butantã  - São Paulo/SP - CEP 05423-905|"
              print column 001,
   "|Inscrição Municipal: 11.73.29.0-3 (se houver campo na nota fiscal)                |"
              print column 001,
   "|Inscrição Estadual: Deixar em branco ou Isento (se houver campo na nota fiscal)       |"
              print column 001,
   "+--------------------------------------------------------------------------------------+"
              skip 1 line
              print column 001,
   "- As notas fiscais da Itaú Auto e Residência  devem ser entregues/enviadas ao Porto Socorro "
              print column 010,
              "(mesmo local que você já envia as NF da Porto Seguro)."
              print column 001,
   "- Em caso de dúvidas sobre a operação: (11) 3366-5571/72 ou porto.socorro@portoseguro.com.br."
              print column 001,
   "- Em caso de dúvidas sobre pagamento: (11) 3366-6068 ou porto.socorro@portoseguro.com.br."
              print column 001,
   "OBS: Se forem cobrados serviços da Porto Seguro e da Itaú Auto e Residência  na mesma nota fiscal,"
              print column 010,
              "a área pagadora devolverá a nota."

           end case
{### NAO EXCLUI POIS MENSAGENS IRAO RETORNAR CONF.EDUARDO ORI. 29/08/2002 ###

           print column 001, "- RECEBA MAIS RAPIDO O SEU SERVICO, ACERTE O ",
                             "VALOR COM NOSSA CENTRAL DE ATENDIMENTO ",
                             "011 3366-6068, ANTES DE ENVIAR A SUA NOTA FISCAL."
           print column 001, "- EMITIR NF PARA: PORTO SEGURO CIA DE SEGUROS ",
                             "GERAIS CNPJ 61.198.164/0001-60 I.E. ",
                             "108.377.122.112 END.: AV.RIO BRANCO 1489 12.AND."
           print column 001, "  BAIRRO: CAMPOS ELISEOS CIDADE: SAO PAULO - SP."
           print column 001, "- ENVIAR NF PARA: PORTO SEGURO CIA DE SEGUROS ",
                             "GERAIS A/C DEPTO.PORTO SOCORRO CAIXA POSTAL ",
                             "13818 CEP: 01216-970 SAO PAULO-SP."
           print column 001, "- POR DETERMINACAO LEGAL, A PORTO SEGURO NAO ",
                             "PODERA EFETUAR O PAGAMENTO DE NOTAS FISCAIS COM ",
                             "VALORES ILEGIVEIS OU COM RASURAS, AS "
           print column 001, "  QUAIS SERAO DEVOLVIDAS."

           # -- OSF 12718 - Fabrica de Software, Katiucia -- #
           if vl_ligcvntip = 64 then
              print column 001, "- O PAGAMENTO DE SERVICOS DE TAXI ESTA "
                              , "LIMITADO A R$ 500,00 (QUINHENTOS REAIS), "
                              , "MAIS O VALOR DO "
                              , "PEDAGIO. VALORES SUPERIORES DEVEM "
           else
              print column 001, "- O PAGAMENTO DE SERVICOS DE TAXI ESTA "
                              , "LIMITADO A R$ 800,00 (QUINHENTOS REAIS), "
                              , "MAIS O VALOR DO "
                              , "PEDAGIO. VALORES SUPERIORES DEVEM "
           end if
           print column 001, "  SER INFORMADOS DE IMEDIATO AO TELEFONE DE APOIO."
           print column 001, "- CASO NAO CONSIGA CUMPRIR O TEMPO DE PREVISAO ",
                             "SOLICITADO, NOS AVISE DE IMEDIATO ATRAVES DO ",
                             "TELEFONE DE APOIO."

           if ws.asitipcod = 12 then # translado
              print column 001, "- LIMITE DE COBERTURA RESTRITO AO VALOR ",
                                "DE R$ 1.500,00 (HUM MIL E QUINHENTOS REAIS)."
           end if
           if ws.asitipcod = 13 then # hospedagem
              if ws.ramcod    = 78    or # transportes
                 ws.ramcod    = 171 then # transportes
                 print column 001, "- LIMITE MAXIMO DE 7 DIAS E R$ 50,00 ",
                                   "(CINQUENTA REAIS) POR DIA."
              else
                 # -- OSF 12718 - Fabrica de Software, Katiucia -- #
                 if vl_ligcvntip = 64 then
                    print column 001, "- LIMITE MAXIMO DE 7 DIAS E R$ 100,00 ",
                                      "(CEM REAIS) POR DIA."
                 else
                    print column 001, "- LIMITE MAXIMO DE 7 DIAS E R$ 150,00 ",
                                      "(CENTO E CINQUENTA REAIS) POR DIA."
                 end if
              end if
           end if
           if ws.asitipcod  =  5   or   # taxi
              ws.asitipcod  = 10   then # aviao
              if ws.ramcod  = 78     or # transportes
                 ws.ramcod  = 171  then # transportes
                 if ws.asimtvcod = 3 then # recup. de veiculos
                    print column 001, "- LIMITE DE R$ 250,00 (DUZENTOS E ",
                                      "CINQUENTA REAIS) PARA RECUPERACAO ",
                                      "DE VEICULOS."
                 else
                    if ws.asimtvcod = 4 then # outras situacoes
                       print column 001, "- LIMITE DE R$ 500,00 (QUINHENTOS ",
                                         "REAIS)."
                    else
                       print column 001, "- LIMITE DE R$ 500,00 (QUINHENTOS ",
                                         "REAIS) PARA ",ws.asimtvdes
                    end if
                 end if
              else
                 if ws.asimtvcod = 3 then # recup. de veiculos
                    print column 001, "- LIMITE DE COBERTURA RESTRITO AO VALOR ",
                                      "DE UMA PASSAGEM AEREA NA CLASSE ECONOMICA."
                 else
                    if ws.asimtvcod = 4 then # outras situacoes
                       print column 001, "- LIMITE DE R$ 500,00 (QUINHENTOS ",
                                         "REAIS)."
                    else
                       # -- OSF 12718 - Fabrica de Software, Katiucia -- #
                       if vl_ligcvntip = 64 then
                          print column 001, "- LIMITE DE R$ 500,00 (QUINHENTOS "
                                          , "REAIS) PARA ", ws.asimtvdes,"."
                       else
                          print column 001, "- LIMITE DE R$ 800,00 (OITOCENTOS "
                                          , "REAIS) PARA ", ws.asimtvdes,"."
                       end if
                    end if
                 end if
              end if
           else
              if ws.asitipcod = 11 then # ambulancia
                 if ws.ramcod = 78   or
                    ws.ramcod = 171 then
                    print column 001, "- LIMITE DE COBERTURA RESTRITO AO VALOR ",
                                      "MAXIMO DE R$ 1.000,00 (HUM MIL REAIS)."
                 else
                    print column 001, "- LIMITE DE COBERTURA RESTRITO AO VALOR ",
                                      "MAXIMO DE R$ 2.500,00 (DOIS MIL E ",
                                      "QUINHENTOS REAIS)."
                 end if
              end if
           end if

### NAO EXCLUI POIS MENSAGENS IRAO RETORNAR CONF.EDUARDO ORI. 29/08/2002 ###}

        end if

end report

#-------------------------------------------#
#               URA ANTIGA                  #
#-------------------------------------------#

#-------------------------------------------#
  function wdatn001_fone_seg()
#-------------------------------------------#

    define l_xml_request  char(32000),
           l_xml_response char(32000),
           l_status       char(00001),
           l_doc_handle   integer,
           l_histserv     char(300),
           l_histserv2    char(300)

    define lr_fonelig  record
        dddtel  like datkveiculo.celdddcod,
        numtel  like datkveiculo.celtelnum
    end record

    define lr_srrinf   record
        srrcoddig like datksrr.srrcoddig,
        socvclcod like datkveiculo.socvclcod,
        srrabvnom like datksrr.srrabvnom
    end record

    define lr_srvinf   record
        atdsrvnum like datmservico.atdsrvnum,
        atdsrvano like datmservico.atdsrvano
    end record

    define lr_seginf   record
        celteldddcod like datmlcl.celteldddcod,
        celtelnum    like datmlcl.celtelnum,
        dddcod       like datmlcl.dddcod,
        lcltelnum    like datmlcl.lcltelnum
    end record

    define lr_retorno  record
        sttsrrsrv char(01),
        dddsegnum like datmlcl.dddcod,
        telsegnum like datmlcl.lcltelnum,
        erro      smallint
    end record

    initialize lr_fonelig.*,
               lr_srvinf.*,
               lr_seginf.*,
               lr_retorno.*,
               l_histserv,
               l_histserv2 to null

    let lr_retorno.sttsrrsrv = "N"

    let lr_fonelig.dddtel = figrc011_xpath(m_doc_handle, "/REQUEST/FONE/DDD")
    let lr_fonelig.numtel = figrc011_xpath(m_doc_handle, "/REQUEST/FONE/NUMERO")

    # VERIFICA SE O TELEFONE PERTENTE A ALGUMA VIATURA.
    whenever error continue
    select distinct socvclcod
      into lr_srrinf.socvclcod
      from datkveiculo
     where (celdddcod = lr_fonelig.dddtel and celtelnum = lr_fonelig.numtel)
        or (nxtdddcod = lr_fonelig.dddtel and nxtnum    = lr_fonelig.numtel)
    whenever error stop

    if  sqlca.sqlcode = 100 then

        # VERIFICA SE O TELEFONE PERTENTE A ALGUM SOCORRISTA.
        whenever error continue
        select distinct srrcoddig
          into lr_srrinf.srrcoddig
          from datksrr
         where (celdddcod = lr_fonelig.dddtel and celtelnum = lr_fonelig.numtel)
            or (nxtdddcod = lr_fonelig.dddtel and nxtnum    = lr_fonelig.numtel)
        whenever error stop

        if  sqlca.sqlcode = 0 then

            # RELACIONA SOCORRISTA COM VEICULO
            select socvclcod
              into lr_srrinf.socvclcod
              from dattfrotalocal
             where srrcoddig = lr_srrinf.srrcoddig

        end if

    end if

    if  sqlca.sqlcode = 0 then

        # BUSCA SERVIÇO EM ATENDIMENTO
        select atdsrvnum,
               atdsrvano
          into lr_srvinf.atdsrvnum,
               lr_srvinf.atdsrvano
          from dattfrotalocal
         where socvclcod  = lr_srrinf.socvclcod

        # BUSCA TELEFONE DO SEGURA EM ATENDIMENTO
        select celteldddcod,
               celtelnum,
               dddcod,
               lcltelnum
          into lr_seginf.celteldddcod,
               lr_seginf.celtelnum,
               lr_seginf.dddcod,
               lr_seginf.lcltelnum
          from datmlcl
         where atdsrvnum = lr_srvinf.atdsrvnum
           and atdsrvano = lr_srvinf.atdsrvano
           and c24endtip = 1

        if  sqlca.sqlcode = 0 then

            if  lr_seginf.celteldddcod is not null and lr_seginf.celteldddcod <> 0 and
                lr_seginf.celtelnum is not null and lr_seginf.celtelnum <> 0 then

                let lr_retorno.dddsegnum = lr_seginf.celteldddcod
                let lr_retorno.telsegnum = lr_seginf.celtelnum
                let lr_retorno.sttsrrsrv = "S"

            else
                if  lr_seginf.dddcod is not null and lr_seginf.dddcod <> 0 and
                    lr_seginf.lcltelnum is not null and lr_seginf.lcltelnum <> 0 then

                    let lr_retorno.dddsegnum = lr_seginf.dddcod
                    let lr_retorno.telsegnum = lr_seginf.lcltelnum
                    let lr_retorno.sttsrrsrv = "S"

                end if
            end if
        end if

    end if

    if  lr_retorno.sttsrrsrv = "S" then

        select srrabvnom
          into lr_srrinf.srrabvnom
          from dattfrotalocal frt,
               datksrr        srr
         where frt.srrcoddig = srr.srrcoddig
           and socvclcod     = lr_srrinf.socvclcod

        let l_histserv  = today, " ", extend(current, hour to second), ": Ligação do QRA ",
                          lr_srrinf.srrabvnom clipped
        let l_histserv2 = " transferido para o cliente (",
                          lr_retorno.dddsegnum using "<<<&&", ") ", lr_retorno.telsegnum using "<<<<<<<<<"

        call cts10g02_historico(lr_srvinf.atdsrvnum,
                                lr_srvinf.atdsrvano,
                                today,
                                current,
                                999999,
                                l_histserv,l_histserv2,"","","")
                      returning lr_retorno.erro

    end if

    let l_xml_response = "<?xml version='1.0' encoding='ISO-8859-1' ?>",
                                "<RESPONSE>",
                                  "<SERVICO>VALIDAR_CELULAR_SOCORRISTA</SERVICO>",
                                  "<VALIDO>", lr_retorno.sttsrrsrv, "</VALIDO>",
                                  "<FONESEGURADO>",
                                    "<DDD>", lr_retorno.dddsegnum using "<<<", "</DDD>",
                                    "<FONE>", lr_retorno.telsegnum using "<<<<<<<<<<", "</FONE>",
                                  "</FONESEGURADO>",
                                "</RESPONSE>"

    return l_xml_response

 end function


# FUNCAO PARA ATUALIZAR A SITUACAO DO SERVICO EM ATENDIMENTO PELO NOVO ACIONAMENTO
# Ueslei Oliveira - 25/05/2011
#-----------------------------------#
function wdatn001_atualiza_servico()
#-----------------------------------#
 #SERVICO
 define lr_atusrv     record
        atdsrvnum     like datmservico.atdsrvnum,    #NUMERO SERVICO ATENDIMENTO
        atdsrvano     like datmservico.atdsrvano,    #ANO SERVICO ATENDIMENTO
        nom           like datmservico.nom      ,    #NOME PADRAO
        atdlibflg     like datmservico.atdlibflg,    #FLAG LIBERACAO ATENDIMENTO
        atddat        like datmservico.atddat,       #DATA ATENDIMENTO
        atdlibdat     like datmservico.atdlibdat,    #DATA LIBERACAO ATENDIMENTO
        atddatprg     like datmservico.atddatprg,    #DATA PROGRAMADA ATENDIMENTO
        atdhorpvt     like datmservico.atdhorpvt,    #HORA PREVISTA ATENDIMENTO
        atdhorprg     like datmservico.atdhorprg,    #HORA PROGRAMADA ATENDIMENTO
        atdlibhor     like datmservico.atdlibhor,    #HORA LIBERACAO ATENDIMENTO
        atdhor        like datmservico.atdhor,       #HORA ATENDIMENTO
        atdpvtretflg  like datmservico.atdpvtretflg, #FLAG DE RETORNO PREVISTO
        asitipcod     like datmservico.asitipcod,    #CODIGO TIPO ASSISTENCIA
        atdvcltip     like datmservico.atdvcltip,    #TIPO DO VEICULO ATENDIMENTO
        atdprinvlcod  like datmservico.atdprinvlcod, #NIVEL DE PRIORIDADE DO ATENDIMENTO
        prslocflg     like datmservico.prslocflg,    #PRESTADOR NO LOCAL DA OCORRENCIA
        ciaempcod     like datmservico.ciaempcod,    #CODIGO DA EMPRESA DA COMPANHIA
        empcod        like datmservico.empcod,       #CODIGO DA EMPRESA
        funmat        like datmservico.funmat,       #FUNCIONARIO MATRICULA
        usrtip        like datmservico.usrtip,       #TIPO USUARIO ATUALIZACAO
        c24opemat     like datmservico.c24opemat,    #MATRICULA DO OPERADOR DO RADIO
        c24opeempcod  like datmservico.c24opeempcod, #CODIGO EMPRESA OPERADOR RADIO
        c24opeusrtip  like datmservico.c24opeusrtip, #TIPO USUARIO OPERADOR RADIO
        atdsoltip     like datmservico.atdsoltip,    #TIPO SOLICITANTE
        c24solnom     like datmservico.c24solnom,    #NOME SOLICITANTE
        atdsrvorg     like datmservico.atdsrvorg,    #ORIGEM SERVICOS ATENDIMENTO CT24HS
        atdrsdflg     like datmservico.atdrsdflg,    #FLAG
        atddfttxt     like datmservico.atddfttxt,    #DESCRICAO DO DEFEITO DO VEICULO
        sblintcod     like datmservico.sblintcod     #CÓDIGO DE INTEGRAÇÃO SIEBEL      #Kelly
 end record

 #ENDERECO DO SERVICO
 define lr_srvend        record
     c24endtip     like datmlcl.c24endtip,   #TIPO ENDERECO
     lclidttxt     like datmlcl.lclidttxt,   #TEXTO DE IDENTIFICACAO DO LOCAL
           lgdtip  like datmlcl.lgdtip,    #TIPO DO LOGRADOURO DO GUIA POSTAL
     lgdnom  like datmlcl.lgdnom,    #NOME DO LOGRADOURO DO GUIA POSTAL
     lgdnum  like datmlcl.lgdnum,    #NUMERO DO LOGRADOURO
     lclbrrnom     like datmlcl.lclbrrnom,   #NOME DO BAIRRO DO LOCAL
     brrnom  like datmlcl.brrnom,    #NOME DO BAIRRO
     cidnom  like datmlcl.cidnom,    #NOME DA CIDADE NO GUIA POSTAL
     ufdcod  like datmlcl.ufdcod,    #CODIGO ESTADO
     lclrefptotxt  like datmlcl.lclrefptotxt,#PONTO DE REFERENCIA DO LOCAL
     lgdcep  like datmlcl.lgdcep,    #NUMERO DO CEP DO LOGRADOURO
     lgdcepcmp     like datmlcl.lgdcepcmp,   #COMPLEMENTO DO CEP DO LOGRADOURO
     c24lclpdrcod  like datmlcl.c24lclpdrcod,#CODIGO PADRONIZACAO LOCAL CENTRAL 24 HORAS
     dddcod  like datmlcl.dddcod,    #CODIGO DE DDD
     lcltelnum     like datmlcl.lcltelnum,   #NUMERO TELEFONE DO LOCAL
     lclcttnom     like datmlcl.lclcttnom,   #NOME PESSOA CONTATO
     lclltt  like datmlcl.lclltt,    #LATITUDE DO LOCAL
     lcllgt  like datmlcl.lcllgt,    #LONGITUDE DO LOCAL
     endcmp  like datmlcl.endcmp,    #COMPLEMENTO DO ENDERECO
     celteldddcod  like datmlcl.celteldddcod,#CODIGO DDD TELEFONE CELULAR
     celtelnum     like datmlcl.celtelnum,   #NUMERO DO TELEFONE CELULAR
     cmlteldddcod  like datmlcl.cmlteldddcod,#NUMERO DDD TELEFONE COMERCIAL
     emeviacod     like datmlcl.emeviacod,   #CODIGO VIA EMERGENCIAL
     cmltelnum     like datmlcl.cmltelnum    #NUMERO TELEFONE CELULAR
 end record

 #PESSOAS DO SERVICO
 define lr_srvpas  record
  passeq     like datmpassageiro.passeq, #SEQUENCIA PASSAGEIRO
  pasnom     like datmpassageiro.pasnom, #NOME PASSAGEIRO
  pasidd     like datmpassageiro.pasidd  #IDADE DO PASSAGEIRO
 end record

 #CENTRAL
 define lr_srvcen  record
  c24astcod  like datmligacao.c24astcod  #CODIGO DO ASSUNTO
 end record


 #HOSPEDAGEM SERVICO
 define lr_srvhdm      record
        hpddiapvsqtd   like datmhosped.hpddiapvsqtd,  #QUANTIDADE DE DIAS PREVISTOS PARA HOSPEDAGEM
        hpdqrtqtd      like datmhosped.hpdqrtqtd,     #QUANTIDADE DE QUARTOS PARA HOSPEDAGEM
        hspsegsit      like datmhosped.hspsegsit,     #SITUACAO DO SEGURADO HOSPEDADO
        hsphotcid      like datmhosped.hsphotcid,     #CIDADE DO HOTEL DE HOSPEDAGEM
        hsphotbrr      like datmhosped.hsphotbrr,     #BAIRRO DO HOTEL DE HOSPEDAGEM
        hsphotrefpnt   like datmhosped.hsphotrefpnt,  #PONTO DE REFERENCIA DO HOTEL DE HOSPEDAGEM
        hsphotcttnom   like datmhosped.hsphotcttnom,  #NOME DO CONTATO NO HOTEL DE HOSPEDAGEM
        hsphottelnum   like datmhosped.hsphottelnum,  #NUMERO DO TELEFONE DO HOTEL DE HOSPEDAGEM
        hsphotuf       like datmhosped.hsphotuf,      #UF DO HOTEL
        hsphotend      like datmhosped.hsphotend      #ENDERECO DO HOTEL
 end record

 define lr_retorno  record
        erro        smallint,
        mensagem    char(1000)
 end record

 define lr_aux      record
        l_contador  smallint,
        l_contador2 smallint,
        l_fixo      smallint,
        l_qtd_end   smallint, #CONTADOR DE ENDERECOS
        l_qtd_tel   smallint, #CONTADOR DE TELEFONES
        l_qtd_eno   smallint, #CONTADOR DE EVENTOS PRIORIZACAO
        l_qtd_pss   smallint, #CONTADOR DE PESSOAS
        l_prievecod smallint, #CODIGO DO EVENTO PRIORIDADE
        l_cancela   smallint, #CANCELA A ATUALIZACAO DO SERVICO
        l_lignum    like datmligacao.lignum,
        l_desc_tel  char(30),
        l_noxml     char(100),
        l_char      char(500)
 end record

 define l_sql char(5000),
        l_atdfnlflg like datmservico.atdfnlflg,
        l_aux_lclrsc smallint, #Stiauação Local Ocorrência
        l_emeviacod  smallint, #Stiauação Local Ocorrência
        l_aux_flgrsdlcl char(1) # Flag Servico em Residencia

 #SETANDO O CANCELAMENTO DA ATUALIZACAO COMO FALSO
 let lr_aux.l_cancela = false

 #SETANDO OS DADOS PADRAO DO XML NAS VARIAVEIS

 let lr_atusrv.atdsrvnum = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/NUMERO_SERVICO_ATENDIMENTO")
 let lr_atusrv.atdsrvano = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/ANO_SERVICO_ATENDIMENTO")
 let lr_atusrv.ciaempcod = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/CODIGO_EMPRESA")

 let lr_atusrv.atddat = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/DATA_ABERTURA_SERVICO")
 let lr_atusrv.atdhor = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/HORA_ABERTURA_SERVICO")
 let lr_atusrv.atddatprg = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/DATA_PROGRAMACAO")
 let lr_atusrv.atdhorprg = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/HORA_PROGRAMACAO")

 let lr_atusrv.atdhorpvt = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/DATA_PREVISAO_ATENDIMENTO_CLIENTE")
 let lr_atusrv.atddfttxt = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/DESCRICAO_MOTIVO_SERVICO")

 ####USUARIO ATUALIZACAO
 ###let lr_atusrv.funmat = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/USUARIO_ATUALIZACAO/MATRICULA")
 ###let lr_atusrv.empcod = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/USUARIO_ATUALIZACAO/EMPRESA")
 ###let lr_atusrv.usrtip = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/USUARIO_ATUALIZACAO/TIPO")
 ###
 #### Agrupa matriculas de sistema do acionamentoWEB
 ###if lr_atusrv.funmat >= 999990 and lr_atusrv.funmat < 999999 then
 ###   let lr_atusrv.funmat = 999999
 ###end if

 #INICIO DO PREPARE DO SERVICO

 let l_sql = 'update datmservico        ',
                     'set atddatprg = ?,',
                         'atdhorprg = ?,',
                         'atdhorpvt = ?,',
                         'atddfttxt = ?,',
                         'sblintcod = ?' #Kelly

 select atdfnlflg into l_atdfnlflg
   from datmservico
  where atdsrvnum = lr_atusrv.atdsrvnum
    and atdsrvano = lr_atusrv.atdsrvano

 if l_atdfnlflg <> 'S' then  # SERVICO EM ABERTO
    #BLOQUEIO DO SERVICO
    let lr_atusrv.c24opemat = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/BLOQUEIO_SERVICO/USUARIO_BLOQUEIO/MATRICULA")
    let lr_atusrv.c24opeempcod = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/BLOQUEIO_SERVICO/USUARIO_BLOQUEIO/EMPRESA")
    let lr_atusrv.c24opeusrtip = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/BLOQUEIO_SERVICO/USUARIO_BLOQUEIO/TIPO")

    if lr_atusrv.c24opemat = 0 then

       let l_sql = l_sql clipped,',c24opemat=null,',
                                 'c24opeempcod=null,',
                                 'c24opeusrtip=null'
     else
        let l_sql = l_sql clipped,',c24opemat=?,',
                                  'c24opeempcod=?,',
                                  'c24opeusrtip=?'
     end if

 else # SERVICO FINALIZADO
    let lr_atusrv.c24opemat = 0
    let lr_atusrv.c24opeempcod = 0
    let lr_atusrv.c24opeusrtip = ''
 end if

 #INICIO DAS TRANSACOES
 begin work

 #ENDERECO SERVICO
 let lr_aux.l_qtd_end = figrc011_xpath(m_doc_handle,"count(/REQUEST/SERVICO_ATUALIZACAO/ENDERECOS/ENDERECO)")
 if  lr_aux.l_cancela = false then
   for lr_aux.l_contador = 1 to lr_aux.l_qtd_end

       initialize lr_srvend.* to null

       let lr_aux.l_char = "/REQUEST/SERVICO_ATUALIZACAO/ENDERECOS/ENDERECO[",lr_aux.l_contador,"]/NOME_CIDADE"
       let lr_srvend.cidnom = figrc011_xpath(m_doc_handle,lr_aux.l_char )

       let lr_aux.l_char = "/REQUEST/SERVICO_ATUALIZACAO/ENDERECOS/ENDERECO[",lr_aux.l_contador,"]/SIGLA_UF"
       let lr_srvend.ufdcod = figrc011_xpath(m_doc_handle,lr_aux.l_char )

       let lr_aux.l_char = "/REQUEST/SERVICO_ATUALIZACAO/ENDERECOS/ENDERECO[",lr_aux.l_contador,"]/NOME_BAIRRO"
       let lr_srvend.brrnom = figrc011_xpath(m_doc_handle,lr_aux.l_char)

       let lr_aux.l_char = "/REQUEST/SERVICO_ATUALIZACAO/ENDERECOS/ENDERECO[",lr_aux.l_contador,"]/NOME_SUB_BAIRRO"
       let lr_srvend.lclbrrnom = figrc011_xpath(m_doc_handle,lr_aux.l_char)

       let lr_aux.l_char = "/REQUEST/SERVICO_ATUALIZACAO/ENDERECOS/ENDERECO[",lr_aux.l_contador,"]/NOME_LOGRADOURO"
       let lr_srvend.lgdnom = figrc011_xpath(m_doc_handle, lr_aux.l_char)

       let lr_aux.l_char = "/REQUEST/SERVICO_ATUALIZACAO/ENDERECOS/ENDERECO[",lr_aux.l_contador,"]/NUMERO_LOGRADOURO"
       let lr_srvend.lgdnum = figrc011_xpath(m_doc_handle, lr_aux.l_char)

       let lr_aux.l_char = "/REQUEST/SERVICO_ATUALIZACAO/ENDERECOS/ENDERECO[",lr_aux.l_contador,"]/DESCRICAO_ENDERECO_COMPLEMENTO"
       let lr_srvend.endcmp = figrc011_xpath(m_doc_handle, lr_aux.l_char)

       let lr_aux.l_char = "/REQUEST/SERVICO_ATUALIZACAO/ENDERECOS/ENDERECO[",lr_aux.l_contador,"]/CODIGO_CEP"
       let lr_srvend.lgdcep = figrc011_xpath(m_doc_handle, lr_aux.l_char)

       let lr_aux.l_char = "/REQUEST/SERVICO_ATUALIZACAO/ENDERECOS/ENDERECO[",lr_aux.l_contador,"]/CODIGO_CEP_COMPLEMENTO"
       let lr_srvend.lgdcepcmp = figrc011_xpath(m_doc_handle, lr_aux.l_char)

       let lr_aux.l_char = "/REQUEST/SERVICO_ATUALIZACAO/ENDERECOS/ENDERECO[",lr_aux.l_contador,"]/NUMERO_LATITUDE"
       let lr_srvend.lclltt = figrc011_xpath(m_doc_handle, lr_aux.l_char)

       let lr_aux.l_char = "/REQUEST/SERVICO_ATUALIZACAO/ENDERECOS/ENDERECO[",lr_aux.l_contador,"]/NUMERO_LONGITUDE"
       let lr_srvend.lcllgt = figrc011_xpath(m_doc_handle, lr_aux.l_char)

       let lr_aux.l_char = "/REQUEST/SERVICO_ATUALIZACAO/ENDERECOS/ENDERECO[",lr_aux.l_contador,"]/TIPO_INDEXACAO"
       let lr_srvend.c24lclpdrcod = figrc011_xpath(m_doc_handle, lr_aux.l_char)

       let lr_aux.l_char = "/REQUEST/SERVICO_ATUALIZACAO/ENDERECOS/ENDERECO[",lr_aux.l_contador,"]/DESCRICAO_PONTO_REFERENCIA"
       let lr_srvend.lclrefptotxt = figrc011_xpath(m_doc_handle, lr_aux.l_char)

       let lr_aux.l_char = "/REQUEST/SERVICO_ATUALIZACAO/ENDERECOS/ENDERECO[",lr_aux.l_contador,"]/TIPO_ENDERECO"
       let lr_srvend.c24endtip = figrc011_xpath(m_doc_handle, lr_aux.l_char)

       let lr_aux.l_char = "/REQUEST/SERVICO_ATUALIZACAO/ENDERECOS/ENDERECO[",lr_aux.l_contador,"]/TELEFONES/TELEFONE/NOME_CONTATO"
       let lr_srvend.lclcttnom = figrc011_xpath(m_doc_handle,lr_aux.l_char )

       # SEPARA TIPO DO LOGARADOURO
       let lr_srvend.lgdtip = ''
       call cts06g11_retira_tipo_lougradouro_navteq(lr_srvend.lgdnom)
            returning lr_srvend.lgdtip
                     ,lr_srvend.lgdnom
       if lr_srvend.lgdtip is null or lr_srvend.lgdtip = ' ' then
          call cts06g11_retira_tipo_lougradouro(lr_srvend.lgdnom)
               returning lr_srvend.lgdtip
                        ,lr_srvend.lgdnom
       end if

       whenever error continue
       if lr_srvend.cidnom <> 'INDEFINIDA' then
          update datmlcl set cidnom = lr_srvend.cidnom,
                   ufdcod = lr_srvend.ufdcod,
                             brrnom = lr_srvend.brrnom,
                             lclbrrnom = lr_srvend.lclbrrnom,
                             lgdtip = lr_srvend.lgdtip,
                             lgdnom = lr_srvend.lgdnom,
                             lgdnum = lr_srvend.lgdnum,
                             endcmp = lr_srvend.endcmp,
                             lgdcep = lr_srvend.lgdcep,
                             lgdcepcmp = lr_srvend.lgdcepcmp,
                             lclltt = lr_srvend.lclltt,
                             lcllgt = lr_srvend.lcllgt,
                             lclcttnom = lr_srvend.lclcttnom,
                       c24lclpdrcod = lr_srvend.c24lclpdrcod,
                       lclrefptotxt = lr_srvend.lclrefptotxt
              where atdsrvnum = lr_atusrv.atdsrvnum
                and atdsrvano = lr_atusrv.atdsrvano
                and c24endtip = lr_srvend.c24endtip

          if lr_srvend.lgdcep is null or lr_srvend.lgdcep = 0 then
             update datmlcl set lgdcep = null,
                                lgdcepcmp = null
                 where atdsrvnum = lr_atusrv.atdsrvnum
                   and atdsrvano = lr_atusrv.atdsrvano
                   and c24endtip = lr_srvend.c24endtip
          end if
       end if
       whenever error stop

       if sqlca.sqlcode <> 0 then
            let lr_aux.l_cancela = true
            let lr_retorno.erro =  sqlca.sqlcode
            let lr_retorno.mensagem = 'Erro ao atualizar servico local em datmlcl'
            exit for
       end if

       if lr_aux.l_cancela = false then
         #TELEFONES DO ENDERECO

         let lr_aux.l_char = "count(/REQUEST/SERVICO_ATUALIZACAO/ENDERECOS/ENDERECO[",lr_aux.l_contador,"]/TELEFONES/TELEFONE)"
         let lr_aux.l_qtd_tel = figrc011_xpath(m_doc_handle,lr_aux.l_char)
         let lr_aux.l_fixo = false
         for lr_aux.l_contador2 = 1 to lr_aux.l_qtd_tel

             let lr_aux.l_char = "/REQUEST/SERVICO_ATUALIZACAO/ENDERECOS/ENDERECO[",lr_aux.l_contador,"]/TELEFONES/TELEFONE[",lr_aux.l_contador2,"]/DESCRICAO_TELEFONE"
             let lr_aux.l_desc_tel = figrc011_xpath(m_doc_handle,lr_aux.l_char)

             case lr_aux.l_desc_tel
                 when 'FIXO'
                      let lr_aux.l_char = "/REQUEST/SERVICO_ATUALIZACAO/ENDERECOS/ENDERECO[",lr_aux.l_contador,"]/TELEFONES/TELEFONE[",lr_aux.l_contador2,"]/CODIGO_DDD"
                      let lr_srvend.dddcod = figrc011_xpath(m_doc_handle,lr_aux.l_char )

                      let lr_aux.l_char = "/REQUEST/SERVICO_ATUALIZACAO/ENDERECOS/ENDERECO[",lr_aux.l_contador,"]/TELEFONES/TELEFONE[",lr_aux.l_contador2,"]/NUMERO_TELEFONE"
                      let lr_srvend.lcltelnum = figrc011_xpath(m_doc_handle,lr_aux.l_char)

                      if lr_srvend.dddcod <> 0
                         and lr_srvend.lcltelnum <> 0 then

                         if lr_aux.l_fixo = true then
                            whenever error continue
                                update datmlcl set cmlteldddcod = lr_srvend.dddcod,
                                                      cmltelnum = lr_srvend.lcltelnum
                                       where atdsrvnum = lr_atusrv.atdsrvnum
                                       and atdsrvano = lr_atusrv.atdsrvano
                                       and c24endtip = lr_srvend.c24endtip
                            whenever error stop

                            if sqlca.sqlcode <> 0 then
                                 let lr_aux.l_cancela = true
                                 let lr_retorno.erro =  sqlca.sqlcode
                                 let lr_retorno.mensagem = 'Erro ao atualizar telefone servico local em datmlcl-telefone fixo'
                                 exit for
                            end if
                         else
                            whenever error continue
                               update datmlcl set dddcod = lr_srvend.dddcod,
                                                  lcltelnum = lr_srvend.lcltelnum
                                   where atdsrvnum = lr_atusrv.atdsrvnum
                                   and atdsrvano = lr_atusrv.atdsrvano
                                   and c24endtip = lr_srvend.c24endtip
                            whenever error stop
                            if sqlca.sqlcode <> 0 then
                               let lr_aux.l_cancela = true
                               let lr_retorno.erro =  sqlca.sqlcode
                               let lr_retorno.mensagem = 'Erro ao atualizar telefone servico local em datmlcl-telefone fixo'
                               exit for
                            end if
                            let lr_aux.l_fixo = true
                         end if
                      end if
                 when 'CELULAR'
                      let lr_aux.l_char = "/REQUEST/SERVICO_ATUALIZACAO/ENDERECOS/ENDERECO[",lr_aux.l_contador,"]/TELEFONES/TELEFONE[",lr_aux.l_contador2,"]/CODIGO_DDD"
                      let lr_srvend.celteldddcod = figrc011_xpath(m_doc_handle,lr_aux.l_char )

                      let lr_aux.l_char = "/REQUEST/SERVICO_ATUALIZACAO/ENDERECOS/ENDERECO[",lr_aux.l_contador,"]/TELEFONES/TELEFONE[",lr_aux.l_contador2,"]/NUMERO_TELEFONE"
                      let lr_srvend.celtelnum = figrc011_xpath(m_doc_handle,lr_aux.l_char)

                      if lr_srvend.celteldddcod <> 0
                         and lr_srvend.celteldddcod <> 0 then
                         whenever error continue
                            update datmlcl set celteldddcod = lr_srvend.celteldddcod,
                                               celtelnum = lr_srvend.celtelnum
                                where atdsrvnum = lr_atusrv.atdsrvnum
                                and atdsrvano = lr_atusrv.atdsrvano
                                and c24endtip = lr_srvend.c24endtip
                         whenever error stop

                         if sqlca.sqlcode <> 0 then
                              let lr_aux.l_cancela = true
                              let lr_retorno.erro =  sqlca.sqlcode
                              let lr_retorno.mensagem = 'Erro ao atualizar celular servico local em datmlcl-telefone celular'
                              exit for
                         end if
                      end if

                 when 'COMERCIAL'
                      let lr_aux.l_char = "/REQUEST/SERVICO_ATUALIZACAO/ENDERECOS/ENDERECO[",lr_aux.l_contador,"]/TELEFONES/TELEFONE[",lr_aux.l_contador2,"]/CODIGO_DDD"
                      let lr_srvend.cmlteldddcod = figrc011_xpath(m_doc_handle,lr_aux.l_char )

                      let lr_aux.l_char = "/REQUEST/SERVICO_ATUALIZACAO/ENDERECOS/ENDERECO[",lr_aux.l_contador,"]/TELEFONES/TELEFONE[",lr_aux.l_contador2,"]/NUMERO_TELEFONE"
                      let lr_srvend.cmltelnum = figrc011_xpath(m_doc_handle,lr_aux.l_char)

                      if lr_srvend.cmlteldddcod <> 0
                         and lr_srvend.celteldddcod <> 0 then
                         whenever error continue
                            update datmlcl set cmlteldddcod = lr_srvend.cmlteldddcod,
                                               cmltelnum = lr_srvend.cmltelnum
                                where atdsrvnum = lr_atusrv.atdsrvnum
                                and atdsrvano = lr_atusrv.atdsrvano
                                and c24endtip = lr_srvend.c24endtip
                         whenever error stop

                         if sqlca.sqlcode <> 0 then
                              let lr_aux.l_cancela = true
                              let lr_retorno.erro =  sqlca.sqlcode
                              let lr_retorno.mensagem = 'Erro ao atualizar telefone servico local em datmlcl'
                              exit for
                         end if
                      end if
             end case
         end for
       end if
   end for
 end if

 #EVENTOS PRIORIZACAO
 let l_aux_flgrsdlcl = 'S' # Sem evento de priorização 10
 if lr_aux.l_cancela = false then
   let lr_aux.l_qtd_eno = figrc011_xpath(m_doc_handle,"count(/REQUEST/SERVICO_ATUALIZACAO/EVENTOS_PRIORIZACAO/EVENTO_PRIORIZACAO)")

   let l_aux_lclrsc = 0 #Sem evento de priorização - #Situação local de ocorrência
   for lr_aux.l_contador = 1 to lr_aux.l_qtd_eno

       let lr_aux.l_char = "/REQUEST/SERVICO_ATUALIZACAO/EVENTOS_PRIORIZACAO/EVENTO_PRIORIZACAO[",lr_aux.l_contador,"]/CODIGO_EVENTO_PRIORIDADE"
       let lr_aux.l_prievecod = figrc011_xpath(m_doc_handle,lr_aux.l_char)

       if lr_aux.l_prievecod = 9 then
          #Inicio - Situação local de ocorrência
          let l_aux_lclrsc = 1 #Existe evento de priorização
          {    whenever error continue
                   update datmlcl set emeviacod = 1
                      where atdsrvnum = lr_atusrv.atdsrvnum
                            and atdsrvano = lr_atusrv.atdsrvano
                            and c24endtip = 1
                whenever error stop
                if sqlca.sqlcode <> 0 then
                    let lr_aux.l_cancela = true
                    let lr_retorno.erro = sqlca.sqlcode
                    let lr_retorno.mensagem = 'Erro ao atualizar servico local em datmlcl'
                    exit for
                end if
          }
          #Fim - Situação local de ocorrência
       end if
       if lr_aux.l_prievecod = 10 then
            let l_aux_flgrsdlcl = 'N'
       end if
   end for
   #Inicio - Situação local de ocorrência
   whenever error continue
      update datmlcl set emeviacod = l_aux_lclrsc #Atualiza a informação do evento
         where atdsrvnum = lr_atusrv.atdsrvnum
               and atdsrvano = lr_atusrv.atdsrvano
               and c24endtip = 1
   whenever error stop
   if sqlca.sqlcode <> 0 then
       let lr_aux.l_cancela = true
       let lr_retorno.erro = sqlca.sqlcode
       let lr_retorno.mensagem = 'Erro ao atualizar servico local em datmlcl'
   end if
   #Fim - Situação local de ocorrência
 end if
 # Atualiza evento de priorizacao 10
 let l_sql = l_sql clipped,',atdrsdflg = "', l_aux_flgrsdlcl clipped, '" '

 #PESSOAS DO SERVICO
 if lr_aux.l_cancela = false then
   let lr_aux.l_qtd_pss = figrc011_xpath(m_doc_handle,"count(/REQUEST/SERVICO_ATUALIZACAO/PESSOAS/PESSOA)")
   for lr_aux.l_contador = 1 to lr_aux.l_qtd_pss

       initialize lr_srvpas.* to null

       let lr_aux.l_char = "/REQUEST/SERVICO_ATUALIZACAO/PESSOAS/PESSOA[",lr_aux.l_contador,"]/SEQUENCIA_SERVICO_PESSOA"
       let lr_srvpas.passeq = figrc011_xpath(m_doc_handle,lr_aux.l_char )

       let lr_aux.l_char = "/REQUEST/SERVICO_ATUALIZACAO/PESSOAS/PESSOA[",lr_aux.l_contador,"]/NOME_PESSOA"
       let lr_srvpas.pasnom = figrc011_xpath(m_doc_handle, lr_aux.l_char)

       let lr_aux.l_char = "/REQUEST/SERVICO_ATUALIZACAO/PESSOAS/PESSOA[",lr_aux.l_contador,"]/QUANTIDADE_IDADE_PESSOA"
       let lr_srvpas.pasidd = figrc011_xpath(m_doc_handle, lr_aux.l_char)

       if lr_srvpas.passeq <> 0 and
            lr_srvpas.pasnom <> " " and
               lr_srvpas.pasidd  then

         whenever error continue
             update datmpassageiro
                 set pasnom = lr_srvpas.pasnom,
                     pasidd = lr_srvpas.pasidd
                where atdsrvnum = lr_atusrv.atdsrvnum
                and atdsrvano = lr_atusrv.atdsrvano
                and passeq = lr_srvpas.passeq
          whenever error stop
          if sqlca.sqlcode <> 0 then
              let lr_aux.l_cancela = true
              let lr_retorno.erro =  sqlca.sqlcode
              let lr_retorno.mensagem = 'Erro ao atualizar servico passageiros em datmpassageiro'
              exit for
          end if
       end if
   end for
 end if

 #HOSPEDAGEM
 if lr_aux.l_cancela = false then
    let lr_srvhdm.hpddiapvsqtd = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/HOSPEDAGEM/QUANTIDADE_DIA")
    let lr_srvhdm.hpdqrtqtd = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/HOSPEDAGEM/QUANTIDADE_QUARTO")
    let lr_srvhdm.hspsegsit = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/HOSPEDAGEM/FLAG_CLIENTE_HOSPEDADO")
    let lr_srvhdm.hsphotend = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/HOSPEDAGEM/ENDERECO/NOME_LOGRADOURO")
    let lr_srvhdm.hsphotuf = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/HOSPEDAGEM/ENDERECO/SIGLA_UF")
    let lr_srvhdm.hsphotcid = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/HOSPEDAGEM/ENDERECO/NOME_CIDADE")
    let lr_srvhdm.hsphotbrr = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/HOSPEDAGEM/ENDERECO/NOME_BAIRRO")
    let lr_srvhdm.hsphotrefpnt = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/HOSPEDAGEM/ENDERECO/DESCRICAO_PONTO_REFERENCIA")
    let lr_srvhdm.hsphotcttnom = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/HOSPEDAGEM/ENDERECO/TELEFONES/TELEFONE/NOME_CONTATO")
    let lr_srvhdm.hsphottelnum =figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/HOSPEDAGEM/ENDERECO/TELEFONES/TELEFONE/CODIGO_DDD"),' ', figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/HOSPEDAGEM/ENDERECO/TELEFONES/TELEFONE/NUMERO_TELEFONE")

    if lr_srvhdm.hpddiapvsqtd <> 0 then
        whenever error continue
           update datmhosped
               set hpddiapvsqtd = lr_srvhdm.hpddiapvsqtd,
                   hpdqrtqtd = lr_srvhdm.hpdqrtqtd,
                   hspsegsit = lr_srvhdm.hspsegsit,
                   hsphotcid = lr_srvhdm.hsphotcid,
                   hsphotbrr = lr_srvhdm.hsphotbrr,
                   hsphotrefpnt = lr_srvhdm.hsphotrefpnt,
                   hsphotcttnom = lr_srvhdm.hsphotcttnom,
                   hsphottelnum = lr_srvhdm.hsphottelnum,
                   hsphotend    = lr_srvhdm.hsphotend,
                   hsphotuf     =lr_srvhdm.hsphotuf
              where atdsrvnum = lr_atusrv.atdsrvnum
              and atdsrvano = lr_atusrv.atdsrvano
        whenever error stop
        if sqlca.sqlcode <> 0 then
          let lr_aux.l_cancela = true
          let lr_retorno.erro =  sqlca.sqlcode
          let lr_retorno.erro = 'Erro ao atualizar servico hospedagem em datmhosped'
        end if
        if sqlca.sqlerrd[3]=0 then
            let lr_aux.l_cancela = true
            let lr_retorno.erro =  sqlca.sqlcode
            let lr_retorno.mensagem = 'Erro numero de linhas afetadas.:',sqlca.sqlerrd[3] clipped,':. atualizacao nao realizada, tabela datmhosped'
         end if
    end if
 end if
 #TRANSPORTE --FALTA FAZER, CONFIRMAR DADOS COM O RAJI


 #EXECUTANDO O UPDATE DO SERVICO

 if lr_aux.l_cancela = false   then
     let l_sql = l_sql clipped,' where atdsrvnum = ? and ',
                               'atdsrvano = ?'

     prepare p_wdatn001_001 from l_sql

     if lr_atusrv.c24opemat <> 0 then
         whenever error continue
         execute p_wdatn001_001 using   lr_atusrv.atddatprg,
                                        lr_atusrv.atdhorprg,
                                        lr_atusrv.atdhorpvt,
                                        lr_atusrv.atddfttxt,
                                        lr_atusrv.sblintcod, #Kelly
                                        lr_atusrv.c24opemat,
                                        lr_atusrv.c24opeempcod,
                                        lr_atusrv.c24opeusrtip,
                                        lr_atusrv.atdsrvnum,
                                        lr_atusrv.atdsrvano

         whenever error stop
         if sqlca.sqlcode <> 0 then
            let lr_aux.l_cancela = true
            let lr_retorno.erro =  sqlca.sqlcode
            let lr_retorno.mensagem = 'Erro ', sqlca.sqlcode, ' atualiza servico em datmservico '
         end if
         if sqlca.sqlerrd[3]=0 then
            let lr_aux.l_cancela = true
            let lr_retorno.erro =  sqlca.sqlcode
            let lr_retorno.mensagem = 'Erro numero de linhas afetadas.:', sqlca.sqlerrd[3], ':. atualizacao nao realizada'
         end if
     end if

     if lr_atusrv.c24opemat = 0 then
         whenever error continue
           execute p_wdatn001_001 using   lr_atusrv.atddatprg,
                                          lr_atusrv.atdhorprg,
                                          lr_atusrv.atdhorpvt,
                                          lr_atusrv.atddfttxt,
                                          lr_atusrv.sblintcod, #Kelly
                                          lr_atusrv.atdsrvnum,
                                          lr_atusrv.atdsrvano
         whenever error stop
         if sqlca.sqlcode <> 0 then
            let lr_aux.l_cancela = true
            let lr_retorno.erro =  sqlca.sqlcode
            let lr_retorno.mensagem = 'Erro ', sqlca.sqlcode, ' atualiza servico em datmservico '
         end if
         if sqlca.sqlerrd[3]=0 then
            let lr_aux.l_cancela = true
            let lr_retorno.erro =  sqlca.sqlcode
            let lr_retorno.mensagem = 'Erro numero de linhas afetadas.:', sqlca.sqlerrd[3], ':. atualizacao nao realizada'
         end if
     end if

 end if

 # Ponto de acesso apos a gravacao do laudo
 # if lr_aux.l_cancela = false
 #     call cts00g07_apos_grvlaudo(lr_atusrv.atdsrvnum,
 #                                 lr_atusrv.atdsrvano)
 # end if

 if lr_aux.l_cancela = true then
    rollback work
    let mr_xml.coderr = lr_retorno.erro
    let mr_xml.msgerr = lr_retorno.mensagem
 else
    commit work
 end if

end function


# FUNCAO PARA INSERIR A ETAPA DO SERVICO EM ATENDIMENTO PELO NOVO ACIONAMENTO
# Ueslei Oliveira - 25/05/2011
#-----------------------------------#
function wdatn001_insere_etapa()
#-----------------------------------#
  define lr_inseta    record
         atdsrvnum    like datmsrvacp.atdsrvnum,
         atdsrvano    like datmsrvacp.atdsrvano,
         atdsrvseq    like datmsrvacp.atdsrvseq,
         atdetpcod    like datmsrvacp.atdetpcod,
         pstcoddig    like datmsrvacp.pstcoddig,
         c24nomctt    like datmsrvacp.c24nomctt,
         socvclcod    like datmsrvacp.socvclcod,
         srrcoddig    like datmsrvacp.srrcoddig,
         dataatu      like datmsrvacp.atdetpdat,
         horaatu      like datmsrvacp.atdetphor,
         funmat       like datmsrvacp.funmat,
         empcod       like datmsrvacp.empcod,
         envtipcod    like datmsrvacp.envtipcod,
         dstqtd       like datmsrvacp.dstqtd,
         atdprvdat    like datmservico.atdprvdat,
         srrltt       like datmservico.srrltt,
         srrlgt       like datmservico.srrlgt,
         canmtvcod    like datmsrvacp.canmtvcod #Kelly
  end record

  define lr_retorno  record
     mensagem char(300),
     erro      smallint
  end record

  define l_dathoretp datetime year to minute,
         l_dathorprv datetime year to minute,
         l_intermin  interval hour to minute,
         l_strdat    char(10),
         l_strhor    char(5),
         l_strdathor char(20),
         l_atdsrvorg like datmservico.atdsrvorg,
         l_atdsrvseq like datmsrvacp.atdsrvseq

  initialize l_atdsrvseq to null
  let l_atdsrvseq = 0

  #call errorlog("ponto 0")

  let lr_inseta.atdsrvnum = figrc011_xpath(m_doc_handle, "/REQUEST/ETAPA/NUMERO_SERVICO_ATENDIMENTO")
  let lr_inseta.atdsrvano = figrc011_xpath(m_doc_handle, "/REQUEST/ETAPA/ANO_SERVICO")
  let lr_inseta.atdsrvseq = figrc011_xpath(m_doc_handle, "/REQUEST/ETAPA/SEQUENCIA_ETAPA")
  let lr_inseta.atdetpcod = figrc011_xpath(m_doc_handle, "/REQUEST/ETAPA/CODIGO_ETAPA_ATENDIMENTO")
  let lr_inseta.pstcoddig = figrc011_xpath(m_doc_handle, "/REQUEST/ETAPA/CODIGO_PRESTADOR")
  if lr_inseta.pstcoddig = 0 then
     initialize lr_inseta.pstcoddig to null
  end if

  let lr_inseta.c24nomctt = figrc011_xpath(m_doc_handle, "/REQUEST/ETAPA/NOME_CONTATO")
  let lr_inseta.socvclcod = figrc011_xpath(m_doc_handle, "/REQUEST/ETAPA/CODIGO_VEICULO_SOCORRO")

  if lr_inseta.socvclcod = 0 then
     initialize lr_inseta.socvclcod to null
  end if

  let lr_inseta.srrcoddig = figrc011_xpath(m_doc_handle, "/REQUEST/ETAPA/CODIGO_SOCORRISTA")

  if lr_inseta.srrcoddig = 0 then
     initialize lr_inseta.srrcoddig to null
  end if

  let lr_inseta.dataatu   = figrc011_xpath(m_doc_handle, "/REQUEST/ETAPA/DATA")
  let lr_inseta.horaatu   = figrc011_xpath(m_doc_handle, "/REQUEST/ETAPA/HORA_MINUTO")
  let lr_inseta.empcod    = figrc011_xpath(m_doc_handle, "/REQUEST/ETAPA/EMPRESA_FUNCIONARIO_PORTO")
  let lr_inseta.funmat    = figrc011_xpath(m_doc_handle, "/REQUEST/ETAPA/MATRICULA_FUNCIONARIO_PORTO")

  # Agrupa matriculas de sistema do acionamentoWEB
  if lr_inseta.funmat = 99993 or lr_inseta.funmat = 99997 or lr_inseta.funmat = 99998 or lr_inseta.funmat = 99999 then
     let lr_inseta.funmat = 999999
  end if

  let lr_inseta.envtipcod = figrc011_xpath(m_doc_handle, "/REQUEST/ETAPA/TIPO_ENVIO")
  let lr_inseta.dstqtd    = figrc011_xpath(m_doc_handle, "/REQUEST/ETAPA/DISTANCIA")
  if lr_inseta.dstqtd > 0 then  # Converte metros para KM
     let lr_inseta.dstqtd = lr_inseta.dstqtd / 1000
  end if

  # DATA e HORA da previsao
  let l_strdathor = figrc011_xpath(m_doc_handle, "/REQUEST/ETAPA/DATA_PREVISAO")
  if l_strdathor is not null and l_strdathor <> ' ' then
     let l_strdathor = l_strdathor[7,10], "-", l_strdathor[4,5], "-", l_strdathor[1,2], " ", l_strdathor[12,16]
      let l_dathorprv = l_strdathor
      # DATA e HORA da etapa
      let l_strdat = lr_inseta.dataatu
      let l_strhor = lr_inseta.horaatu
      let l_strdathor = l_strdat[7,10], "-", l_strdat[4,5], "-", l_strdat[1,2], " ", l_strhor
      let l_dathoretp = l_strdathor
      # Tempo de previsao informix
      let l_intermin = l_dathorprv - l_dathoretp
      let lr_inseta.atdprvdat = "00:00"
      let lr_inseta.atdprvdat = lr_inseta.atdprvdat + l_intermin
  else
      let lr_inseta.atdprvdat = null
  end if

  let lr_inseta.srrltt    = figrc011_xpath(m_doc_handle, "/REQUEST/ETAPA/LATITUDE_RECURSO")
  let lr_inseta.srrlgt    = figrc011_xpath(m_doc_handle, "/REQUEST/ETAPA/LONGITUDE_RECURSO")
  let lr_inseta.canmtvcod = figrc011_xpath(m_doc_handle, "/REQUEST/ETAPA/MOTIVO_CANCELAMENTO") #Kelly

  whenever error continue
  select atdsrvorg into l_atdsrvorg
    from datmservico
   where atdsrvnum = lr_inseta.atdsrvnum
     and atdsrvano = lr_inseta.atdsrvano
  whenever error stop
  if l_atdsrvorg = 9 and lr_inseta.atdetpcod = 4 then
     let lr_inseta.atdetpcod = 3
  end if

  whenever error continue

  if lr_inseta.pstcoddig > 0 and lr_inseta.srrcoddig > 0 then

     if lr_inseta.atdsrvseq > 0 then

        select atdsrvseq
          into l_atdsrvseq
          from datmsrvacp
         where atdsrvnum = lr_inseta.atdsrvnum
           and atdsrvano = lr_inseta.atdsrvano
           and atdetpcod = lr_inseta.atdetpcod
           and atdetpdat = lr_inseta.dataatu
           and atdetphor = lr_inseta.horaatu
           and empcod    = lr_inseta.empcod
           and funmat    = lr_inseta.funmat
           and pstcoddig = lr_inseta.pstcoddig
           and srrcoddig = lr_inseta.srrcoddig
           and atdsrvseq = lr_inseta.atdsrvseq

     else

        select atdsrvseq
          into l_atdsrvseq
          from datmsrvacp
         where atdsrvnum = lr_inseta.atdsrvnum
           and atdsrvano = lr_inseta.atdsrvano
           and atdetpcod = lr_inseta.atdetpcod
           and atdetpdat = lr_inseta.dataatu
           and atdetphor = lr_inseta.horaatu
           and empcod    = lr_inseta.empcod
           and funmat    = lr_inseta.funmat
           and pstcoddig = lr_inseta.pstcoddig
           and srrcoddig = lr_inseta.srrcoddig

     end if

  else
     if lr_inseta.pstcoddig > 0 then

        if lr_inseta.atdsrvseq > 0 then

           select atdsrvseq
             into l_atdsrvseq
             from datmsrvacp
            where atdsrvnum = lr_inseta.atdsrvnum
              and atdsrvano = lr_inseta.atdsrvano
              and atdetpcod = lr_inseta.atdetpcod
              and atdetpdat = lr_inseta.dataatu
              and atdetphor = lr_inseta.horaatu
              and empcod    = lr_inseta.empcod
              and funmat    = lr_inseta.funmat
              and pstcoddig = lr_inseta.pstcoddig
              and atdsrvseq = lr_inseta.atdsrvseq

        else

           select atdsrvseq
             into l_atdsrvseq
             from datmsrvacp
            where atdsrvnum = lr_inseta.atdsrvnum
              and atdsrvano = lr_inseta.atdsrvano
              and atdetpcod = lr_inseta.atdetpcod
              and atdetpdat = lr_inseta.dataatu
              and atdetphor = lr_inseta.horaatu
              and empcod    = lr_inseta.empcod
              and funmat    = lr_inseta.funmat
              and pstcoddig = lr_inseta.pstcoddig

        end if

     else

        if lr_inseta.atdsrvseq > 0 then

           select atdsrvseq
             into l_atdsrvseq
             from datmsrvacp
            where atdsrvnum = lr_inseta.atdsrvnum
              and atdsrvano = lr_inseta.atdsrvano
              and atdetpcod = lr_inseta.atdetpcod
              and atdetpdat = lr_inseta.dataatu
              and atdetphor = lr_inseta.horaatu
              and empcod    = lr_inseta.empcod
              and funmat    = lr_inseta.funmat
              and atdsrvseq = lr_inseta.atdsrvseq

        else

           select atdsrvseq
             into l_atdsrvseq
             from datmsrvacp
            where atdsrvnum = lr_inseta.atdsrvnum
              and atdsrvano = lr_inseta.atdsrvano
              and atdetpcod = lr_inseta.atdetpcod
              and atdetpdat = lr_inseta.dataatu
              and atdetphor = lr_inseta.horaatu
              and empcod    = lr_inseta.empcod
              and funmat    = lr_inseta.funmat
        end if
     end if
  end if

  if l_atdsrvseq = 0 then # BLOQUEIO PARA INSERIR ETAPA APENAS UMA VEZ

     call cts10g04_insere_etapa_mq(lr_inseta.atdsrvnum
                                  ,lr_inseta.atdsrvano
                                  ,lr_inseta.atdsrvseq
                                  ,lr_inseta.atdetpcod
                                  ,lr_inseta.pstcoddig
                                  ,lr_inseta.c24nomctt
                                  ,lr_inseta.socvclcod
                                  ,lr_inseta.srrcoddig
                                  ,lr_inseta.dataatu
                                  ,lr_inseta.horaatu
                                  ,lr_inseta.funmat
                                  ,lr_inseta.empcod
                                  ,lr_inseta.envtipcod
                                  ,lr_inseta.dstqtd
                                  ,lr_inseta.atdprvdat
                                  ,lr_inseta.srrltt
                                  ,lr_inseta.srrlgt
                                  ,lr_inseta.canmtvcod)
          returning lr_retorno.erro

     if lr_retorno.erro <> 0 then
        let mr_xml.coderr = lr_retorno.erro
        let mr_xml.msgerr = 'Problemas na atualizacao da etapa'
     end if
  end if
  whenever error stop

end function

# FUNCAO PARA INSERIR O HISTORICO DO SERVICO EM ATENDIMENTO PELO NOVO ACIONAMENTO
# Ueslei Oliveira - 25/05/2011
#-----------------------------------#
function wdatn001_insere_historico()
#-----------------------------------#
 define lr_inshis     record
    atdsrvnum         like datmservhist.atdsrvnum,
    atdsrvano         like datmservhist.atdsrvano,
    ligdat            like datmservhist.ligdat   ,
    lighorinc         like datmservhist.lighorinc,
    c24funmat         like datmservhist.c24funmat,
    usrtip            like datmservhist.c24usrtip,
    empcod            like datmservhist.c24empcod
 end record

 define hist_wdatn001 record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
    hist5             like datmservhist.c24srvdsc
 end record

 define lr_retorno  record
        sttsrrsrv   char(01),
        dddsegnum   like datmlcl.dddcod,
        telsegnum   like datmlcl.lcltelnum,
        erro        smallint
 end record

 define l_aux_tam      smallint,
          l_aux_inicio   smallint,
          l_historico    char(2000),
          l_aux_fim      smallint,
          l_aux_cont     smallint,
          l_aux_char     char(70),
          l_validador    smallint,
          l_txtlighorinc char(8),
          l_tamtxt       smallint

 initialize lr_inshis.*,
            hist_wdatn001.*,
            lr_retorno.* to null

 let lr_inshis.atdsrvnum = figrc011_xpath(m_doc_handle, "/REQUEST/HISTORICO/NUMERO_SERVICO_ATENDIMENTO")
 let lr_inshis.atdsrvano = figrc011_xpath(m_doc_handle, "/REQUEST/HISTORICO/ANO_SERVICO")
 let lr_inshis.ligdat    = figrc011_xpath(m_doc_handle, "/REQUEST/HISTORICO/DATA")
 let l_txtlighorinc      = figrc011_xpath(m_doc_handle, "/REQUEST/HISTORICO/HORA_MINUTO")
 let lr_inshis.c24funmat = figrc011_xpath(m_doc_handle, "/REQUEST/HISTORICO/MATRICULA_FUNCIONARIO_PORTO")
 let lr_inshis.usrtip    = figrc011_xpath(m_doc_handle, "/REQUEST/HISTORICO/TIPO_FUNCIONARIO_PORTO")

 let l_tamtxt = length(l_txtlighorinc)
 if l_tamtxt = 5 then
 	  let l_txtlighorinc = l_txtlighorinc clipped, ":00"
 end if
 let lr_inshis.lighorinc = l_txtlighorinc

 # Agrupa matriculas de sistema do acionamentoWEB
 if lr_inshis.c24funmat = 99997 or lr_inshis.c24funmat = 99998 or lr_inshis.c24funmat = 99999 then
    let lr_inshis.c24funmat = 999999
 end if

 let lr_inshis.empcod    = figrc011_xpath(m_doc_handle, "/REQUEST/HISTORICO/EMPRESA_FUNCIONARIO_PORTO")
 let l_historico   = figrc011_xpath(m_doc_handle, "/REQUEST/HISTORICO/DESCRICAO_SERVICO")
 let l_aux_inicio        = 1
 let l_aux_tam     = 70
 let l_aux_fim     = l_aux_tam
 let l_validador         = true

 #---------------------------------------------------------------------------------
 # Enquanto existir dados dados na descricao do servico, o historico sera inserido
 #---------------------------------------------------------------------------------
 while l_validador

     let hist_wdatn001.hist1 = ""
     let hist_wdatn001.hist2 = ""
     let hist_wdatn001.hist3 = ""
     let hist_wdatn001.hist4 = ""
     let hist_wdatn001.hist5 = ""

     for l_aux_cont = 1 to 5
        let l_aux_char = ""
        let l_aux_char = l_historico[l_aux_inicio,l_aux_fim]

        let l_aux_inicio = l_aux_inicio + l_aux_tam
        let l_aux_fim = l_aux_inicio + l_aux_tam

        if l_aux_char = " " or l_aux_char is null then
            let l_validador = false
            exit for
        else
            case l_aux_cont
                 when 1
                     let hist_wdatn001.hist1 = l_aux_char
                 when 2
                     let hist_wdatn001.hist2 = l_aux_char
                 when 3
                     let hist_wdatn001.hist3 = l_aux_char
                 when 4
                     let hist_wdatn001.hist4 = l_aux_char
                 when 5
                     let hist_wdatn001.hist5 = l_aux_char
            end case
        end if
     end for

     whenever error continue

     call cts10g02_historico_mq(lr_inshis.*,hist_wdatn001.*)
                          returning lr_retorno.erro

     whenever error stop

 end while

 if lr_retorno.erro <> 0 then
    let mr_xml.coderr = lr_retorno.erro
    let mr_xml.msgerr = 'Problemas na atualizacao do historico'
 end if

end function

# FUNCAO PARA DESASSOCIAR SERVICO MULTIPLO PELO NOVO ACIONAMENTO
#-----------------------------------#
function wdatn001_desassociar_multiplo()
#-----------------------------------#
 define lr_multiplo record
    atdsrvnum     like datmservico.atdsrvnum,    #NUMERO SERVICO ATENDIMENTO
    atdsrvano     like datmservico.atdsrvano     #ANO SERVICO ATENDIMENTO
 end record

 define lr_retorno  record
    resultado              smallint,
    mensagem               char(100)
 end record

 let lr_multiplo.atdsrvnum = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_MULTIPLO/NUMERO_SERVICO_ATENDIMENTO")
 let lr_multiplo.atdsrvano = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_MULTIPLO/ANO_SERVICO_ATENDIMENTO")

 call cts29g00_remover_multiplo(lr_multiplo.atdsrvnum,
                                lr_multiplo.atdsrvano)
          returning lr_retorno.resultado,
                    lr_retorno.mensagem

 if lr_retorno.resultado <> 1 then
 	  let mr_xml.flgval = "N"
    let mr_xml.coderr = lr_retorno.resultado
    let mr_xml.msgerr = 'Problemas ao desassociar do multiplo'
    display "ERRO wdatn001_desassociar_multiplo: ", lr_retorno.resultado, " ", lr_retorno.mensagem clipped, " ", lr_multiplo.atdsrvnum using "#######", "-", lr_multiplo.atdsrvano using "##"
 else
 	  let mr_xml.flgval = "S"
 	  let mr_xml.coderr = 0
    let mr_xml.msgerr = "Desassociacao realizada com sucesso"
 end if

end function


# FUNCAO PARA DESASSOCIAR SERVICO MULTIPLO PELO NOVO ACIONAMENTO
#-----------------------------------#
function wdatn001_valida_cancelamento_servico()
#-----------------------------------#
 define lr_cancelamento record
    atdsrvnum     like datmservico.atdsrvnum,    #NUMERO SERVICO ATENDIMENTO
    atdsrvano     like datmservico.atdsrvano     #ANO SERVICO ATENDIMENTO
 end record

 define lr_retorno  record
    resultado              smallint,
    mensagem               char(100)
 end record

 define l_socopgnum like dbsmopg.socopgnum

 let lr_cancelamento.atdsrvnum = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_CANCELAMENTO/NUMERO_SERVICO_ATENDIMENTO")
 let lr_cancelamento.atdsrvano = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_CANCELAMENTO/ANO_SERVICO_ATENDIMENTO")

 select dbsmopg.socopgnum
   into l_socopgnum
   from dbsmopgitm, dbsmopg
  where dbsmopgitm.atdsrvnum = lr_cancelamento.atdsrvnum  and
        dbsmopgitm.atdsrvano = lr_cancelamento.atdsrvano  and
        dbsmopg.socopgnum    = dbsmopgitm.socopgnum   and
        dbsmopg.socopgsitcod <> 8

 if sqlca.sqlcode = 0  then
 	  let mr_xml.flgval = "N"
    let mr_xml.coderr = 1
    let mr_xml.msgerr = 'Servico consta na OP: ', l_socopgnum using "<<<<<<&", ' cancelamento nao autorizado'
 else
 	  let mr_xml.flgval = "S"
 	  let mr_xml.coderr = 0
    let mr_xml.msgerr = "Servico pode ser cancelado"
 end if

end function


#------------------------------------------------------#
#     PARAMETROS PARA IDENTIFICAR O PRAZO DOS SERVICO  #
#       E A PRIORIDADE DA LIGACAO                      #
#------------------------------------------------------#
#         OXXEYYGZZZHI                                 #
#         OXXEYYGZZZHP                                 #
#         OXXEYYGZZZIF                                 #
#         OXXEYYGZZZID                                 #
#         OXXEYYGZZZPF                                 #
#         OXXEYYGZZZPD                                 #
#                                                      #
#  O = Origem                                          #
#  E = Empresa                                         #
#  G = Grupo de Assunto                                #
#  HI = Hora serviço Imediato                          #
#  HP = Hora serviço Programado                        #
#  IF = Priorização serviço Imediato fora do prazo     #
#  ID = Priorização serviço Imediato dentro do prazo   #
#  PF = Priorização serviço Programado fora do prazo   #
#  PD = Priorização serviço Programado dentro do prazo #
#------------------------------------------------------#
#
# FUNCAO PARA VALIDAR A PRIORIDADE DA LIGACAO DO SOCORRISTA DE ACORDO COM OS DADOS DO SERVICO
#-----------------------------------#
function wdatn001_verifica_prioridade_ligacao()
#-----------------------------------#

 define lr_xml record
         atdsrvnum like datmservico.atdsrvnum
     end record

     define lr_servico record
         atdsrvorg       like datmservico.atdsrvorg,
         atdsrvano       like datmservico.atdsrvano,
         ciaempcod       like datmservico.ciaempcod,
         c24astagp       like datkassunto.c24astagp,
         c24astcod       like datmligacao.c24astcod,
         atdsrvseq       like datmservico.atdsrvseq,
         pstcoddig       like datmsrvacp.pstcoddig,
         atdvclsgl       like datkuraligcad.atdvclsgl,
         socvclcod       like datmsrvacp.socvclcod,
         srrcoddig       like datmsrvacp.srrcoddig
     end record

     define l_grlchv         like datkgeral.grlchv
     define l_grlchv_hora    char(60)
     define l_grlinf         like datkgeral.grlinf
     define l_prazo          char(2) # Valores: IF,ID,PF,PD
     define l_tempo          integer
     define l_xml_response   char(32000)


     initialize lr_servico.* to null
     initialize l_xml_response to null
     initialize l_grlchv to null
     initialize l_grlchv_hora to null
     initialize l_grlinf to null
     initialize l_prazo  to null

     let lr_xml.atdsrvnum = figrc011_xpath(m_doc_handle, "/REQUEST/QRU/NUMERO")

     # VERIFICA A HORA DE LIBERACAO MAIS A PREVISAO INFORMADA AO SEGURADO E A HORA PROGRAMADA
     whenever error continue
     select atdsrvorg,
            atdsrvano,
            ciaempcod,
            atdsrvseq
       into lr_servico.atdsrvorg,
            lr_servico.atdsrvano,
            lr_servico.ciaempcod,
            lr_servico.atdsrvseq
       from datmservico srv1
      where srv1.atdsrvnum = lr_xml.atdsrvnum
        and srv1.atdsrvano = (select max(atdsrvano)
                                from datmservico srv2
                               where srv2.atdsrvnum = srv1.atdsrvnum)
     whenever error stop


     # BUSCA O GRUPO DE ASSUNTO DO SERVICO
     whenever error continue
        select a.c24astagp,
               b.c24astcod
          into lr_servico.c24astagp,
               lr_servico.c24astcod
          from datkassunto a,
               datmligacao b
         where a.c24astcod = b.c24astcod
           and b.lignum = (select min(lignum)
                             from datmligacao d
                             where d.atdsrvnum = lr_xml.atdsrvnum
                               and d.atdsrvano = lr_servico.atdsrvano)
      whenever error stop

     #BUSCA O ACIONAMENTO DO SERVICO
     whenever error continue
        select pstcoddig,
               socvclcod,
               srrcoddig
          into lr_servico.pstcoddig,
               lr_servico.socvclcod,
               lr_servico.srrcoddig
          from datmsrvacp
         where atdsrvnum = lr_xml.atdsrvnum
           and atdsrvano = lr_servico.atdsrvano
           and atdsrvseq = lr_servico.atdsrvseq
     whenever error stop

      #BUSCA O ACIONAMENTO DO SERVICO
     whenever error continue
        select atdvclsgl
          into lr_servico.atdvclsgl
          from datkveiculo
         where socvclcod = lr_servico.socvclcod
     whenever error stop



     call wdatn001_busca_prazo_ligacao(lr_xml.atdsrvnum,
                                       lr_servico.atdsrvano,
                                       lr_servico.atdsrvorg,
                                       lr_servico.ciaempcod,
                                       lr_servico.c24astagp)
                             returning l_prazo,l_grlchv_hora,l_tempo

     call wdatn001_busca_parametros(2,l_prazo,
                                    lr_servico.atdsrvorg,
                                    lr_servico.ciaempcod,
                                    lr_servico.c24astagp)
                          returning l_grlchv ,l_grlinf

     let l_grlchv_hora = l_grlchv_hora clipped,';',l_tempo using "<<<<<<",';',
                         l_grlchv clipped,';',l_grlinf using "<<<"

     # Grava os dados da ligacao para a presentar no relatorio
     call wdatn001_grava_ligacao(lr_servico.atdsrvorg,lr_xml.atdsrvnum,lr_servico.atdsrvano,
                                 lr_servico.ciaempcod,lr_servico.c24astcod,lr_servico.pstcoddig,
                                 lr_servico.atdvclsgl,lr_servico.srrcoddig,l_grlchv_hora)


     let l_xml_response = "<?xml version='1.0' encoding='ISO-8859-1' ?>",
                               "<RESPONSE>",
                                 "<SERVICO>VERIFICA_PRIORIDADE_LIGACAO</SERVICO>",
                                 "<PRIORIDADE>", l_grlinf using "<<<", "</PRIORIDADE>",
                                 "<ERRO>",
                                    "<NUMERO>0</NUMERO>",
                                    "<MENSAGEM></MENSAGEM>",
                                 "</ERRO>",
                               "</RESPONSE>"

    return l_xml_response

end function

# FUNCAO PARA BUSCAR O PRAZO PARA QUE O SOCORRISTA FALE COM A CENTRAL
#-----------------------------------#
function wdatn001_busca_prazo_ligacao(param)
#-----------------------------------#

   define param record
         atdsrvnum like datmservico.atdsrvnum,
         atdsrvano like datmservico.atdsrvano,
         atdsrvorg like datmservico.atdsrvorg,
         ciaempcod like datmservico.ciaempcod,
         c24astagp like datkassunto.c24astagp
   end record

   define lr_prazo record
         atdlibdat like datmservico.atdlibdat,
         atdlibhor like datmservico.atdlibhor,
         atddatprg like datmservico.atddatprg,
         atdhorprg like datmservico.atdhorprg,
         atdhorpvt like datmservico.atdhorpvt,
         atdetpcod like datmservico.atdetpcod
   end record


   define lr_data_hora record
          antes   datetime year to minute,
          depois  datetime year to minute,
          servico datetime year to minute,
          ligacao datetime year to minute,
          hora    char(2)  ,
          minuto  char(2)
   end record

   define l_grlchv      like datkgeral.grlchv
   define l_tempo       integer
   define l_prazo       char(2) # Valores: IF,ID,PF,PD


   initialize lr_data_hora.* to null
   initialize lr_prazo.*     to null
   initialize l_grlchv       to null
   initialize l_tempo        to null
   initialize l_prazo        to null


    whenever error continue
     select atdlibdat,
            atdlibhor,
            atddatprg,
            atdhorprg,
            atdhorpvt,
            atdetpcod
       into lr_prazo.atdlibdat,
            lr_prazo.atdlibhor,
            lr_prazo.atddatprg,
            lr_prazo.atdhorprg,
            lr_prazo.atdhorpvt,
            lr_prazo.atdetpcod
       from datmservico
      where atdsrvnum = param.atdsrvnum
        and atdsrvano = param.atdsrvano

     whenever error stop

      # VERIFICA SE O SERVICO EH IMEDIATO OU PROGRAMADO
      if lr_prazo.atddatprg is not null and
         lr_prazo.atdhorprg is not null then
         let l_grlchv = 'HP'
      else
         let l_grlchv = 'HI'
      end if

      call wdatn001_busca_parametros(1,l_grlchv,
                                     param.atdsrvorg,
                                     param.ciaempcod,
                                     param.c24astagp)
                           returning l_grlchv,l_tempo


      # APENAS PARA SERVICOS COM ETAPA DE ACIONADO SERA VERIFICADO A HORA DE LIBERACAO OU DE PROGRAMACAO
      if lr_prazo.atdetpcod = 3 or
         lr_prazo.atdetpcod = 4 or
         lr_prazo.atdetpcod = 10 then

         # SERVICO PROGRAMADO
         if lr_prazo.atddatprg is not null and
            lr_prazo.atdhorprg is not null then

            # SEPARA A HORA E O MINUTO, POIS O INFORMIX NAO SOMA DOIS CAMPOS DE HORA
            let lr_data_hora.hora   = extend(lr_prazo.atdhorprg, hour to hour)
            let lr_data_hora.minuto = extend(lr_prazo.atdhorprg, minute to minute)

            # SOMA COM A DATA PARA SER UM DATETIME,
            # POIS QUANDO FOR MEIA NOITE NOS TEREMOS QUE CALCULAR COM A DATA ANTERIOR
            let lr_data_hora.servico = lr_prazo.atddatprg

            let lr_data_hora.servico = lr_data_hora.servico +
                                       lr_data_hora.hora units hour +
                                       lr_data_hora.minuto units minute


            # SOMA AS HORAS COM UNITS HOUR, PORQUE O INFORMIX NAO TRABALHA MUITO BEM SOMANDO OS CAMPOS
            let lr_data_hora.antes  = lr_data_hora.servico - l_tempo units minute
            let lr_data_hora.depois = lr_data_hora.servico + l_tempo units minute
            let lr_data_hora.ligacao = current

            let l_prazo = "P"

         else
            # SERVICO IMEDIATO
            # SEPARA A HORA E O MINUTO, POIS O INFORMIX NAO SOMA DOIS CAMPOS DE HORA
            let lr_data_hora.hora   = extend(lr_prazo.atdlibhor, hour to hour)
            let lr_data_hora.minuto = extend(lr_prazo.atdlibhor, minute to minute)

            # SOMA COM A DATA PARA SER UM DATETIME,
            # POIS QUANDO FOR MEIA NOITE NOS TEREMOS QUE CALCULAR COM A DATA ANTERIOR
            let lr_data_hora.servico = lr_prazo.atdlibdat

            let lr_data_hora.servico = lr_data_hora.servico +
                                       lr_data_hora.hora units hour +
                                       lr_data_hora.minuto units minute


            if lr_prazo.atdhorpvt is not null then

               let lr_data_hora.hora   = 0
               let lr_data_hora.minuto = 0

               # TEMOS QUE SOMAR COM A PREVISAO INFORMADA AO CLIENTE
               let lr_data_hora.hora   = extend(lr_prazo.atdhorpvt, hour to hour)
               let lr_data_hora.minuto = extend(lr_prazo.atdhorpvt, minute to minute)

               let lr_data_hora.servico = lr_data_hora.servico +
                                          lr_data_hora.hora units hour +
                                          lr_data_hora.minuto units minute

            end if

            let lr_data_hora.antes  = lr_data_hora.servico - l_tempo units minute
            let lr_data_hora.depois = lr_data_hora.servico + l_tempo units minute

            let lr_data_hora.ligacao = current

            let l_prazo = "I"

         end if

         # VERIFICA SE O PRAZO ESTA ENTRE O LIMITE PARAMETRIZADO
         if lr_data_hora.ligacao >= lr_data_hora.antes and
            lr_data_hora.ligacao <= lr_data_hora.depois then
            let l_prazo = l_prazo clipped, "D"
         else
            let l_prazo = l_prazo clipped, "F"
         end if

      else
      # SERVICO COM ETAPA DIFERENTE DE ACIONADO
         if lr_prazo.atddatprg is not null and
            lr_prazo.atdhorprg is not null then
            let l_prazo = "PF"
         else
            let l_prazo = "IF"
         end if
      end if


 return l_prazo,l_grlchv,l_tempo

end function


# FUNCAO PARA GRAVAR OS DADOS QUE IRAO COMPOR O RELATORIO
#-----------------------------------#
function wdatn001_grava_ligacao(param)
#-----------------------------------#

   define param record
         atdsrvorg       like datmservico.atdsrvorg,
         atdsrvnum       like datmservico.atdsrvnum,
         atdsrvano       like datmservico.atdsrvano,
         ciaempcod       like datmservico.ciaempcod,
         c24astcod       like datkassunto.c24astcod,
         pstcoddig       like datmsrvacp.pstcoddig,
         atdvclsgl       like datkuraligcad.atdvclsgl,
         srrcoddig       like datmsrvacp.srrcoddig,
         grlchv          char(60)
     end record

     define l_data  datetime year to second

     let l_data = current


     if param.c24astcod is null or param.c24astcod = '' then
        let param.c24astcod = 0
     end if

     if param.pstcoddig is null or param.pstcoddig = '' then
        let param.pstcoddig = 0
     end if

     if param.atdvclsgl is null or param.atdvclsgl = '' then
        let param.atdvclsgl = 0
     end if

     if param.srrcoddig is null or param.srrcoddig = '' then
        let param.srrcoddig = 0
     end if



      whenever error continue
        insert into datkuraligcad (atdsrvnum,
                                   atdsrvano,
                                   lighordat,
                                   atdsrvorg,
                                   ciaempcod,
                                   c24astcod,
                                   pstcoddig,
                                   atdvclsgl,
                                   srrcoddig,
                                   ligpddcod)
                           values (param.atdsrvnum,
                                   param.atdsrvano,
                                   l_data         ,
                                   param.atdsrvorg,
                                   param.ciaempcod,
                                   param.c24astcod,
                                   param.pstcoddig,
                                   param.atdvclsgl,
                                   param.srrcoddig,
                                   param.grlchv)
     whenever error stop


end function



# FUNCAO PARA BUSCAR O VALOR DO PARAMETRO A SER ESCOLHIDO
#-----------------------------------#
function wdatn001_busca_parametros(param)
#-----------------------------------#

   define param record
         tipo       smallint,
         chave      like datkgeral.grlchv,
         atdsrvorg  like datmservico.atdsrvorg,
         ciaempcod  like datmservico.ciaempcod,
         c24astagp  like datkassunto.c24astagp
   end record

   define l_grlinf like datkgeral.grlinf
   define l_grlchv like datkgeral.grlchv

   initialize l_grlinf to null


    # MONTA A CHAVE PARA BUSCAR O PARAMETRO DA HORA DO SERVICO
     let l_grlchv = 'PSOO',param.atdsrvorg using '<&',
                    'E',param.ciaempcod using '<&',
                    'G',param.c24astagp clipped,
                     param.chave clipped

     whenever error continue
       select grlinf
         into l_grlinf
         from datkgeral
        where grlchv = l_grlchv
     whenever error stop

     if l_grlinf is null or l_grlinf = '' then

        case param.tipo
           when 1
                # MONTA A CHAVE PARA BUSCAR O PARAMETRO DA HORA DO SERVICO
                let l_grlchv = 'PSOO',param.atdsrvorg using '<&',
                               'E',param.ciaempcod using '<&',
                               'G000',param.chave clipped

                whenever error continue
                   select grlinf
                     into l_grlinf
                     from datkgeral
                    where grlchv = l_grlchv
                 whenever error stop

                if l_grlinf is null or l_grlinf = '' then

                    # MONTA A CHAVE PARA BUSCAR O PARAMETRO DA HORA DO SERVICO
                    let l_grlchv = 'PSOO00E00G000',param.chave clipped

                    whenever error continue
                      select grlinf
                        into l_grlinf
                        from datkgeral
                       where grlchv = l_grlchv
                    whenever error stop

                    if l_grlinf is null or l_grlinf = '' then
                       let l_grlinf = 120
                    end if
                end if

           when 2
                # MONTA A CHAVE PARA BUSCAR O PARAMETRO DA PRIORIDADE DO SERVICO
                let l_grlchv = 'PSOO',param.atdsrvorg using '<&',
                               'E',param.ciaempcod using '<&',
                               'G000',param.chave clipped

                whenever error continue
                   select grlinf
                     into l_grlinf
                     from datkgeral
                    where grlchv = l_grlchv
                 whenever error stop

                if l_grlinf is null or l_grlinf = '' then

                    # MONTA A CHAVE PARA BUSCAR O PARAMETRO DA HORA DO SERVICO
                    let l_grlchv = 'PSOO00E00G000',param.chave clipped

                    whenever error continue
                      select grlinf
                        into l_grlinf
                        from datkgeral
                       where grlchv = l_grlchv
                    whenever error stop

                    if l_grlinf is null or l_grlinf = '' then
                       let l_grlinf = 9
                    end if
                end if
         end case
     end if


     return l_grlchv,l_grlinf

end function

#Kelly - Inicio - Carga
#------------------------------------------#
function wdatn001_apos_grv_laudo()
#------------------------------------------#

     define lr_xml record
         atdsrvnum like datmservico.atdsrvnum,
         atdsrvano like datmservico.atdsrvano
     end record
     initialize lr_xml.* to null

     # EXTRAI DADOS DO XML

     let lr_xml.atdsrvnum = figrc011_xpath(m_doc_handle, "/REQUEST/SIEBEL/NUMERO_SERVICO_ATENDIMENTO")
     let lr_xml.atdsrvano = figrc011_xpath(m_doc_handle, "/REQUEST/SIEBEL/ANO_SERVICO_ATENDIMENTO")

     #Chamada da função relacionada aos processos após a gravação do laudo
     call cts00g07_apos_grvlaudo(lr_xml.atdsrvnum,
                                 lr_xml.atdsrvano)

end function
#Kelly - Fim - Carga

#Kelly - Inicio - Receber Cancelamento
#------------------------------------------#
function wdatn001_cancela_acionamento()
#------------------------------------------#

     define lr_xml record
           atdsrvnum          like datmsrvacp.atdsrvnum,
           atdsrvano          like datmsrvacp.atdsrvano,
           canmtvcod          like datmsrvacp.canmtvcod,
           funmat             like isskfunc.funmat,
           empcod             like isskfunc.empcod,
           usrtip             like isskfunc.usrtip
     end record

     define l_retorno         smallint
     define l_xml_response char(32000)

     initialize lr_xml.* to null
     initialize  l_xml_response to null

     # EXTRAI DADOS DO XML
     let lr_xml.atdsrvnum = figrc011_xpath(m_doc_handle, "/REQUEST/CANCELAMENTO/NUMERO_SERVICO_ATENDIMENTO")
     let lr_xml.atdsrvano = figrc011_xpath(m_doc_handle, "/REQUEST/CANCELAMENTO/ANO_SERVICO")
     let lr_xml.canmtvcod = figrc011_xpath(m_doc_handle, "/REQUEST/CANCELAMENTO/MOTIVO_CANCELAMENTO")
     let lr_xml.funmat = figrc011_xpath(m_doc_handle, "/REQUEST/CANCELAMENTO/MATRICULA")
     let lr_xml.empcod = figrc011_xpath(m_doc_handle, "/REQUEST/CANCELAMENTO/CODIGO_EMPRESA")
     let lr_xml.usrtip = figrc011_xpath(m_doc_handle, "/REQUEST/CANCELAMENTO/TIPO_USUARIO")

     #Chamada da função para processar o cancelamento do acionamento
     call cts00m43_cancela_acionamento(lr_xml.atdsrvnum,
                                       lr_xml.atdsrvano,
                                       lr_xml.canmtvcod,
                                       lr_xml.funmat,
                                       lr_xml.empcod,
                                       lr_xml.usrtip)
                                       returning l_retorno

     let l_xml_response = "<RESPONSE>",
                          "  <SERVICO>CANCELAR_ACIONAMENTO</SERVICO>",
                          "  <RETORNO_SIEBEL>",
                          "       <CODERRO>",l_retorno clipped, "</CODERRO>",
                          "  </RETORNO_SIEBEL>",
                          "</RESPONSE>"
     return l_xml_response

end function
#Kelly - Fim - Receber Cancelamento

#Kelly - Inicio - Localiza Prestador
#------------------------------------------#
function wdatn001_localizar_prestador()
#------------------------------------------#

     define lr_xml record
           atdsrvnum          like datmsrvacp.atdsrvnum,
           atdsrvano          like datmsrvacp.atdsrvano
     end record

     define lr_retorno         record
            codigoErro         smallint,
            mensagemErro       char(100),
            lgdnom             like datmlcl.lgdnom,
            lgdnum             like datmlcl.lgdnum,
            ufdcod             like datmlcl.ufdcod,
            cidnom             like datmlcl.cidnom,
            brrnom             like datmlcl.brrnom,
            lgdtip             like datmlcl.lgdtip,
            lclltt             like datmmdtmvt.lclltt,
            lcllgt             like datmmdtmvt.lcllgt,
            distancia          decimal(8,4)
     end record

     define l_xml_response char(32000)
     define m_resumoHora       datetime hour to fraction

     initialize lr_xml.* to null
     initialize  l_xml_response to null

     # EXTRAI DADOS DO XML
     let lr_xml.atdsrvnum = figrc011_xpath(m_doc_handle, "/REQUEST/ACOMPANHAMENTO/NUMERO_SERVICO_ATENDIMENTO")
     let lr_xml.atdsrvano = figrc011_xpath(m_doc_handle, "/REQUEST/ACOMPANHAMENTO/ANO_SERVICO")

     let m_resumoHora = current

     #Chamada da função para buscar a localização do prestador
     call cts00m43_localizar_prestador(lr_xml.atdsrvnum,
                                      lr_xml.atdsrvano)
                                      returning lr_retorno.codigoErro
                                               ,lr_retorno.mensagemErro
                                               ,lr_retorno.lgdtip
                                               ,lr_retorno.lgdnom
                                               ,lr_retorno.lgdnum
                                               ,lr_retorno.ufdcod
                                               ,lr_retorno.cidnom
                                               ,lr_retorno.brrnom
                                               ,lr_retorno.lclltt
                                               ,lr_retorno.lcllgt
                                               ,lr_retorno.distancia

     let l_xml_response = "<RESPONSE>",
                          "  <SERVICO>LOCALIZAR_PRESTADOR</SERVICO>",
                          "  <LOCALIZACAO_PRESTADOR>",
                          "       <CODERRO>",lr_retorno.codigoErro clipped, " </CODERRO>",
                          "       <MSGERRO>",lr_retorno.mensagemErro clipped, " </MSGERRO>",
                          "       <TIPO_LOGRADOURO>", lr_retorno.lgdtip clipped, "</TIPO_LOGRADOURO>",
                          "       <LOGRADOURO>",lr_retorno.lgdnom clipped, " </LOGRADOURO>",
                          "       <NUMERO_LOGRADOURO>",lr_retorno.lgdnum clipped, " </NUMERO_LOGRADOURO>",
                          "       <UF>",lr_retorno.ufdcod clipped, "</UF>",
                          "       <CIDADE>",lr_retorno.cidnom clipped, " </CIDADE>",
                        	 "       <BAIRRO>",lr_retorno.brrnom clipped, " </BAIRRO>",
                          "       <LATITUDE_VIATURA>",lr_retorno.lclltt clipped, " </LATITUDE_VIATURA>",
                          "       <LONGITUDE_VIATURA>",lr_retorno.lcllgt clipped, " </LONGITUDE_VIATURA>",
                        	 "       <DISTANCIA>",lr_retorno.distancia clipped, "</DISTANCIA>",
                          "  </LOCALIZACAO_PRESTADOR>",
                          "</RESPONSE>"

     return l_xml_response

end function
#Kelly - Fim - Localiza Prestador


{
    PSI-2015-05269/IN - NovaUra
    TelefoneEnum[
        Fixo = 1,
        Fax = 2,
        Celular = 3,
        Nextel = 4
    ]
}
function wdatn001_incluir_telefone_socorrista()

    define lr_xml    record
           celdddcod like datksrr.celdddcod,
           celtelnum like datksrr.celtelnum,
           nxtdddcod like datksrr.nxtdddcod,
           nxtnum    like datksrr.nxtnum,
           cgccpfnum like datksrr.cgccpfnum,
           cgccpfdig like datksrr.cgccpfdig,
           srrcoddig like datksrr.srrcoddig,
           teltip    smallint
    end record

    define lr_dados_antigos record
           celdddcod        like datksrr.celdddcod,
           celtelnum        like datksrr.celtelnum,
           nxtdddcod        like datksrr.nxtdddcod,
           nxtnum           like datksrr.nxtnum
    end record

    define lr_retorno record
           codigo     smallint,
           mensagem   char(100)
    end record

    define lr_ctd18g01_param record
           srrcoddig  like  datmsrrhst.srrcoddig
          ,srrhsttxt  like  datmsrrhst.srrhsttxt
          ,caddat     like  datmsrrhst.caddat
          ,cademp     like  datmsrrhst.cademp
          ,cadmat     like  datmsrrhst.cadmat
          ,cadusrtip  like  datmsrrhst.cadusrtip
    end record

    define l_msg  char(200)
    define l_coderro smallint

    define l_xml_response  char(32000)

    initialize lr_xml.* to null
    initialize lr_retorno.* to null
    initialize l_xml_response to null
    initialize lr_dados_antigos.* to null
    initialize lr_ctd18g01_param.* to null

    let lr_xml.teltip    = figrc011_xpath(m_doc_handle, "/REQUEST/TELEFONE/TIPO")
    let lr_xml.srrcoddig = figrc011_xpath(m_doc_handle, "/REQUEST/QRA/NUMERO")
    let lr_xml.cgccpfnum = figrc011_xpath(m_doc_handle, "/REQUEST/CPF/NUMERO")
    let lr_xml.cgccpfdig = figrc011_xpath(m_doc_handle, "/REQUEST/CPF/DIGITO")

    case lr_xml.teltip
        when 1
            let lr_retorno.codigo   = 1
            let lr_retorno.mensagem = "Telefone nao pode ser fixo!"
        when 2
            let lr_retorno.codigo   = 1
            let lr_retorno.mensagem = "Telefone nao pode ser fax!"
        when 3
            let lr_xml.celdddcod = figrc011_xpath(m_doc_handle, "/REQUEST/TELEFONE/DDD")
            let lr_xml.celtelnum = figrc011_xpath(m_doc_handle, "/REQUEST/TELEFONE/NUMERO")

            whenever error continue

                select celdddcod
                      ,celtelnum
                  into lr_dados_antigos.celdddcod
                      ,lr_dados_antigos.celtelnum
                  from datksrr
                 where srrcoddig = lr_xml.srrcoddig

                update datksrr set
                       celdddcod = lr_xml.celdddcod,
                       celtelnum = lr_xml.celtelnum,
                       atldat    = today,
                       atlemp    = 09,
                       atlmat    = 99991
                 where srrcoddig = lr_xml.srrcoddig


                if sqlca.sqlcode = 0 then

                    let lr_ctd18g01_param.srrcoddig = lr_xml.srrcoddig
                    let lr_ctd18g01_param.caddat    = today
                    let lr_ctd18g01_param.cademp    = 09
                    let lr_ctd18g01_param.cadmat    = 99991
                    let lr_ctd18g01_param.cadusrtip = "F"

                    let lr_ctd18g01_param.srrhsttxt = "----- Telefone cadastrado pela Ura -----"

                    call ctd18g01_grava_hist(lr_ctd18g01_param.*) returning l_coderro, l_msg

                    let lr_ctd18g01_param.srrhsttxt = "Telefone antigo: ", lr_dados_antigos.celdddcod using "<<", " - ", lr_dados_antigos.celtelnum using "<<<<<<<<<"

                    call ctd18g01_grava_hist(lr_ctd18g01_param.*) returning l_coderro, l_msg

                    let lr_ctd18g01_param.srrhsttxt = "Telefone novo: ", lr_xml.celdddcod using "<<", " - ", lr_xml.celtelnum using "<<<<<<<<<"

                    call ctd18g01_grava_hist(lr_ctd18g01_param.*) returning l_coderro, l_msg

                    let lr_ctd18g01_param.srrhsttxt = "Registrado com o CPF: ", lr_xml.cgccpfnum using "<<<<<<<<<", "-", lr_xml.cgccpfdig using "<<"

                    call ctd18g01_grava_hist(lr_ctd18g01_param.*) returning l_coderro, l_msg

                    let lr_retorno.codigo   = 0
                    let lr_retorno.mensagem = "Telefone atualizado com sucesso!"

                else
                    let lr_retorno.codigo   = 2
                    let lr_retorno.mensagem = "Erro ao realizar o update!"
                end if
            whenever error stop
        when 4
            let lr_xml.nxtdddcod = figrc011_xpath(m_doc_handle, "/REQUEST/TELEFONE/DDD")
            let lr_xml.nxtnum    = figrc011_xpath(m_doc_handle, "/REQUEST/TELEFONE/NUMERO")

            whenever error continue

                select nxtdddcod
                      ,nxtnum
                  into lr_dados_antigos.nxtdddcod
                      ,lr_dados_antigos.nxtnum
                  from datksrr
                 where srrcoddig = lr_xml.srrcoddig

                update datksrr set
                       nxtdddcod = lr_xml.nxtdddcod,
                       nxtnum    = lr_xml.nxtnum,
                       atldat    = today,
                       atlemp    = 09,
                       atlmat    = 99991
                 where srrcoddig = lr_xml.srrcoddig


                if sqlca.sqlcode = 0 then

                    let lr_ctd18g01_param.srrcoddig = lr_xml.srrcoddig
                    let lr_ctd18g01_param.caddat    = today
                    let lr_ctd18g01_param.cademp    = 09
                    let lr_ctd18g01_param.cadmat    = 99991
                    let lr_ctd18g01_param.cadusrtip = "F"

                    let lr_ctd18g01_param.srrhsttxt = "----- Telefone cadastrado pela Ura -----"

                    call ctd18g01_grava_hist(lr_ctd18g01_param.*) returning l_coderro, l_msg

                    let lr_ctd18g01_param.srrhsttxt = "Telefone antigo: ", lr_dados_antigos.nxtdddcod using "<<", " - ", lr_dados_antigos.nxtnum using "<<<<<<<<<"

                    call ctd18g01_grava_hist(lr_ctd18g01_param.*) returning l_coderro, l_msg

                    let lr_ctd18g01_param.srrhsttxt = "Telefone novo: ", lr_xml.nxtdddcod using "<<", " - ", lr_xml.nxtnum using "<<<<<<<<<"

                    call ctd18g01_grava_hist(lr_ctd18g01_param.*) returning l_coderro, l_msg

                    let lr_ctd18g01_param.srrhsttxt = "Registrado com o CPF: ", lr_xml.cgccpfnum using "<<<<<<<<<", "-", lr_xml.cgccpfdig using "<<"

                    call ctd18g01_grava_hist(lr_ctd18g01_param.*) returning l_coderro, l_msg

                    let lr_retorno.codigo   = 0
                    let lr_retorno.mensagem = "Telefone atualizado com sucesso!"

                else
                    let lr_retorno.codigo   = 2
                    let lr_retorno.mensagem = "Erro ao realizar o update!"
                end if
            whenever error stop
        otherwise
            let lr_retorno.codigo   = 1
            let lr_retorno.mensagem = "Tipo de telefone nao encontrado"
    end case

    let l_xml_response = "<?xml version='1.0' encoding='ISO-8859-1' ?>",
                          "<RESPONSE>",
                            "<SERVICO>INCLUIR_TELEFONE_SOCORRISTA</SERVICO>",
                            "<RETORNO>",
                               "<NUMERO>", lr_retorno.codigo using "<<<&","</NUMERO>",
                               "<MENSAGEM>", lr_retorno.mensagem clipped,"</MENSAGEM>",
                            "</RETORNO>",
                          "</RESPONSE>"
    return l_xml_response

end function

{
    PSI-2015-05269/IN - NovaUra

}
function wdatn001_incluir_telefone_veiculo()

    define lr_xml    record
           celdddcod like datkveiculo.celdddcod,
           celtelnum like datkveiculo.celtelnum,
           nxtdddcod like datkveiculo.nxtdddcod,
           nxtnum    like datkveiculo.nxtnum,
           socvclcod like datkveiculo.socvclcod,
           teltip    smallint,
           cgccpfnum like datksrr.cgccpfnum,
           cgccpfdig like datksrr.cgccpfdig
    end record

    define lr_dados_antigos record
           celdddcod        like datkveiculo.celdddcod,
           celtelnum        like datkveiculo.celtelnum,
           nxtdddcod        like datkveiculo.nxtdddcod,
           nxtnum           like datkveiculo.nxtnum
    end record

    define lr_retorno   record
           codigo   smallint,
           mensagem char(100)
    end record

    define lr_ctb85g01_param record
           tipo      like datmcadalthst.hstide
          ,codigo    like datmcadalthst.conchv
          ,texto     like datmcadalthst.hsttex
          ,caddat    like datmcadalthst.caddat
          ,cademp    like datmcadalthst.cademp
          ,cadmat    like datmcadalthst.cadmat
          ,cadusrtip like datmcadalthst.cadusrtip
    end record

    define l_msg  char(200)
    define l_coderro smallint
    define l_xml_response char(32000)

    initialize lr_xml.* to null
    initialize lr_retorno.* to null
    initialize l_xml_response to null
    initialize lr_dados_antigos.* to null
    initialize lr_ctb85g01_param.* to null

    let lr_xml.teltip    = figrc011_xpath(m_doc_handle, "/REQUEST/TELEFONE/TIPO")
    let lr_xml.socvclcod = figrc011_xpath(m_doc_handle, "/REQUEST/VEICULO/NUMERO")
    let lr_xml.cgccpfnum = figrc011_xpath(m_doc_handle, "/REQUEST/CPF/NUMERO")
    let lr_xml.cgccpfdig = figrc011_xpath(m_doc_handle, "/REQUEST/CPF/DIGITO")

    case lr_xml.teltip
        when 1
            let lr_retorno.codigo   = 1
            let lr_retorno.mensagem = "Telefone nao pode ser fixo!"
        when 2
            let lr_retorno.codigo   = 1
            let lr_retorno.mensagem = "Telefone nao pode ser fax!"
        when 3
            let lr_xml.celdddcod = figrc011_xpath(m_doc_handle, "/REQUEST/TELEFONE/DDD")
            let lr_xml.celtelnum = figrc011_xpath(m_doc_handle, "/REQUEST/TELEFONE/NUMERO")

            whenever error continue

                select celdddcod
                      ,celtelnum
                  into lr_dados_antigos.celdddcod
                      ,lr_dados_antigos.celtelnum
                  from datkveiculo
                 where socvclcod = lr_xml.socvclcod


                update datkveiculo set
                       celdddcod = lr_xml.celdddcod,
                       celtelnum = lr_xml.celtelnum,
                       atldat    = today,
                       atlemp    = 09,
                       atlmat    = 99991
                 where socvclcod = lr_xml.socvclcod


                if sqlca.sqlcode = 0 then

                    let lr_ctb85g01_param.tipo      = 1
                    let lr_ctb85g01_param.codigo    = lr_xml.socvclcod
                    let lr_ctb85g01_param.caddat    = today
                    let lr_ctb85g01_param.cademp    = 09
                    let lr_ctb85g01_param.cadmat    = 99991
                    let lr_ctb85g01_param.cadusrtip = "F"


                    let lr_ctb85g01_param.texto = "----- Telefone cadastrado pela Ura -----"

                    call ctb85g01_grava_hist(lr_ctb85g01_param.*) returning l_coderro, l_msg

                    let lr_ctb85g01_param.texto = "Telefone antigo: ", lr_dados_antigos.celdddcod using "<<", " - ", lr_dados_antigos.celtelnum using "<<<<<<<<<"

                    call ctb85g01_grava_hist(lr_ctb85g01_param.*) returning l_coderro, l_msg

                    let lr_ctb85g01_param.texto = "Telefone novo: ", lr_xml.celdddcod using "<<", " - ", lr_xml.celtelnum using "<<<<<<<<<"

                    call ctb85g01_grava_hist(lr_ctb85g01_param.*) returning l_coderro, l_msg

                    let lr_ctb85g01_param.texto = "Registrado com o CPF: ", lr_xml.cgccpfnum using "<<<<<<<<<", "-", lr_xml.cgccpfdig using "<<"

                    call ctb85g01_grava_hist(lr_ctb85g01_param.*) returning l_coderro, l_msg


                    let lr_retorno.codigo   = 0
                    let lr_retorno.mensagem = "Telefone atualizado com sucesso!"

                else
                    let lr_retorno.codigo   = 2
                    let lr_retorno.mensagem = "Erro ao realizar o update!"
                end if
            whenever error stop

        when 4
            let lr_xml.nxtdddcod = figrc011_xpath(m_doc_handle, "/REQUEST/TELEFONE/DDD")
            let lr_xml.nxtnum    = figrc011_xpath(m_doc_handle, "/REQUEST/TELEFONE/NUMERO")

            whenever error continue

                select nxtdddcod
                      ,nxtnum
                  into lr_dados_antigos.nxtdddcod
                      ,lr_dados_antigos.nxtnum
                  from datkveiculo
                 where socvclcod = lr_xml.socvclcod


                update datkveiculo set
                       nxtdddcod = lr_xml.nxtdddcod,
                       nxtnum    = lr_xml.nxtnum,
                       atldat    = today,
                       atlemp    = 09,
                       atlmat    = 99991
                 where socvclcod = lr_xml.socvclcod


                if sqlca.sqlcode = 0 then

                    let lr_ctb85g01_param.tipo      = 1
                    let lr_ctb85g01_param.codigo    = lr_xml.socvclcod
                    let lr_ctb85g01_param.caddat    = today
                    let lr_ctb85g01_param.cademp    = 09
                    let lr_ctb85g01_param.cadmat    = 99991
                    let lr_ctb85g01_param.cadusrtip = "F"


                    let lr_ctb85g01_param.texto = "----- Telefone cadastrado pela Ura -----"

                    call ctb85g01_grava_hist(lr_ctb85g01_param.*) returning l_coderro, l_msg

                    let lr_ctb85g01_param.texto = "Telefone antigo: ", lr_dados_antigos.nxtdddcod using "<<", " - ", lr_dados_antigos.nxtnum using "<<<<<<<<<"

                    call ctb85g01_grava_hist(lr_ctb85g01_param.*) returning l_coderro, l_msg

                    let lr_ctb85g01_param.texto = "Telefone novo: ", lr_xml.nxtdddcod using "<<", " - ", lr_xml.nxtnum using "<<<<<<<<<"

                    call ctb85g01_grava_hist(lr_ctb85g01_param.*) returning l_coderro, l_msg

                    let lr_ctb85g01_param.texto = "Registrado com o CPF: ", lr_xml.cgccpfnum using "<<<<<<<<<", "-", lr_xml.cgccpfdig using "<<"

                    call ctb85g01_grava_hist(lr_ctb85g01_param.*) returning l_coderro, l_msg



                    let lr_retorno.codigo   = 0
                    let lr_retorno.mensagem = "Telefone atualizado com sucesso!"

                else
                    let lr_retorno.codigo   = 2
                    let lr_retorno.mensagem = "Erro ao realizar o update!"
                end if
            whenever error stop

        otherwise
            let lr_retorno.codigo   = 1
            let lr_retorno.mensagem = "Tipo de telefone nao encontrado"
    end case


    let l_xml_response = "<?xml version='1.0' encoding='ISO-8859-1' ?>",
                      "<RESPONSE>",
                        "<SERVICO>INCLUIR_TELEFONE_VEICULO</SERVICO>",
                        "<RETORNO>",
                           "<NUMERO>", lr_retorno.codigo using "<<<&","</NUMERO>",
                           "<MENSAGEM>", lr_retorno.mensagem clipped,"</MENSAGEM>",
                        "</RETORNO>",
                      "</RESPONSE>"
    return l_xml_response

end function


{
    PSI-2015-05269/IN - NovaUra
}
function wdatn001_incluir_telefone_base()

    define lr_xml    record
           dddcod    like dpaksocor.dddcod,
           teltxt    like dpaksocor.teltxt,
           celdddnum like dpaksocor.celdddnum,
           celtelnum like dpaksocor.celtelnum,
           pstcoddig like dpaksocor.pstcoddig,
           cgccpfnum like dpaksocor.cgccpfnum,
           cgccpfdig like dpaksocor.cgccpfdig,
           teltip    smallint
    end record

    define lr_dados_antigos record
           dddcod           like dpaksocor.dddcod,
           teltxt           like dpaksocor.teltxt,
           celdddnum        like dpaksocor.celdddnum,
           celtelnum        like dpaksocor.celtelnum
    end record

    define lr_retorno   record
           codigo   smallint,
           mensagem char(100)
    end record

    define lr_ctc00m24_param  record
           pstcoddig          like dbsmhstprs.pstcoddig,
           prshstdes          like dbsmhstprs.prshstdes,
           empcod             like isskfunc.empcod,
           usrtip             like isskfunc.usrtip,
           funmat             like isskfunc.funmat,
           funnom             like isskfunc.funnom
    end record

    define l_msg  char(200)
    define l_coderro smallint
    define l_xml_response  char(32000)

    initialize lr_xml.* to null
    initialize lr_retorno.* to null
    initialize l_xml_response to null
    initialize lr_dados_antigos.* to null
    initialize lr_ctc00m24_param.* to null

    let lr_xml.teltip    = figrc011_xpath(m_doc_handle, "/REQUEST/TELEFONE/TIPO")
    let lr_xml.pstcoddig = figrc011_xpath(m_doc_handle, "/REQUEST/BASE/NUMERO")
    let lr_xml.cgccpfnum = figrc011_xpath(m_doc_handle, "/REQUEST/CPF/NUMERO")
    let lr_xml.cgccpfdig = figrc011_xpath(m_doc_handle, "/REQUEST/CPF/DIGITO")

    case lr_xml.teltip
        when 1
            let lr_xml.dddcod = figrc011_xpath(m_doc_handle, "/REQUEST/TELEFONE/DDD")
            let lr_xml.teltxt = figrc011_xpath(m_doc_handle, "/REQUEST/TELEFONE/NUMERO")

            whenever error continue

                select dddcod,
                       teltxt
                  into lr_dados_antigos.dddcod,
                       lr_dados_antigos.teltxt
                  from dpaksocor
                 where pstcoddig = lr_xml.pstcoddig

                update dpaksocor set
                       dddcod    = lr_xml.dddcod,
                       teltxt    = lr_xml.teltxt,
                       atldat    = today,
                       usrtip    = "F",
                       empcod    = 09,
                       funmat    = 99991
                 where pstcoddig = lr_xml.pstcoddig

                if sqlca.sqlcode = 0 then

                    let lr_ctc00m24_param.pstcoddig = lr_xml.pstcoddig
                    let lr_ctc00m24_param.empcod    = 09
                    let lr_ctc00m24_param.usrtip    = "F"
                    let lr_ctc00m24_param.funmat    = 09

                    let lr_ctc00m24_param.prshstdes = "----- Telefone cadastrado pela Ura -----"

                    call ctc00m24_logarHistoricoPrest(lr_ctc00m24_param.*) returning l_coderro, l_msg

                    let lr_ctc00m24_param.prshstdes = "Telefone antigo: ", lr_dados_antigos.dddcod using "<<", " - ", lr_dados_antigos.teltxt clipped

                    call ctc00m24_logarHistoricoPrest(lr_ctc00m24_param.*) returning l_coderro, l_msg

                    let lr_ctc00m24_param.prshstdes = "Telefone novo: ", lr_xml.dddcod using "<<", " - ", lr_xml.teltxt clipped

                    call ctc00m24_logarHistoricoPrest(lr_ctc00m24_param.*) returning l_coderro, l_msg

                    let lr_ctc00m24_param.prshstdes = "Registrado com o CPF: ", lr_xml.cgccpfnum using "<<<<<<<<<", "-", lr_xml.cgccpfdig using "<<"

                    call ctc00m24_logarHistoricoPrest(lr_ctc00m24_param.*) returning l_coderro, l_msg


                    let lr_retorno.codigo   = 0
                    let lr_retorno.mensagem = "Telefone atualizado com sucesso!"
                else
                    let lr_retorno.codigo   = 2
                    let lr_retorno.mensagem = "Erro ao realizar o update!"
                end if
            whenever error stop
        when 2
            let lr_retorno.codigo   = 1
            let lr_retorno.mensagem = "Telefone nao pode ser fax!"
        when 3
            let lr_xml.celdddnum = figrc011_xpath(m_doc_handle, "/REQUEST/TELEFONE/DDD")
            let lr_xml.celtelnum = figrc011_xpath(m_doc_handle, "/REQUEST/TELEFONE/NUMERO")
            whenever error continue

                select celdddnum,
                       celtelnum
                  into lr_dados_antigos.celdddnum,
                       lr_dados_antigos.celtelnum
                  from dpaksocor
                 where pstcoddig = lr_xml.pstcoddig

                update dpaksocor set
                       celdddnum = lr_xml.celdddnum,
                       celtelnum = lr_xml.celtelnum,
                       atldat    = today,
                       usrtip    = "F",
                       empcod    = 09,
                       funmat    = 99991
                 where pstcoddig = lr_xml.pstcoddig

                if sqlca.sqlcode = 0 then

                    let lr_ctc00m24_param.pstcoddig = lr_xml.pstcoddig
                    let lr_ctc00m24_param.empcod    = 09
                    let lr_ctc00m24_param.usrtip    = "F"
                    let lr_ctc00m24_param.funmat    = 09

                    let lr_ctc00m24_param.prshstdes = "----- Telefone cadastrado pela Ura -----"

                    call ctc00m24_logarHistoricoPrest(lr_ctc00m24_param.*) returning l_coderro, l_msg

                    let lr_ctc00m24_param.prshstdes = "Telefone antigo: ", lr_dados_antigos.celdddnum using "<<", " - ", lr_dados_antigos.celtelnum using "<<<<<<<<<"

                    call ctc00m24_logarHistoricoPrest(lr_ctc00m24_param.*) returning l_coderro, l_msg

                    let lr_ctc00m24_param.prshstdes = "Telefone novo: ", lr_xml.celdddnum using "<<", " - ", lr_xml.celtelnum using "<<<<<<<<<"

                    call ctc00m24_logarHistoricoPrest(lr_ctc00m24_param.*) returning l_coderro, l_msg

                    let lr_ctc00m24_param.prshstdes = "Registrado com o CPF: ", lr_xml.cgccpfnum using "<<<<<<<<<", "-", lr_xml.cgccpfdig using "<<"

                    call ctc00m24_logarHistoricoPrest(lr_ctc00m24_param.*) returning l_coderro, l_msg

                    let lr_retorno.codigo   = 0
                    let lr_retorno.mensagem = "Telefone atualizado com sucesso!"
                else
                    let lr_retorno.codigo   = 2
                    let lr_retorno.mensagem = "Erro ao realizar o update!"
                end if
            whenever error stop
        when 4
            let lr_retorno.codigo   = 1
            let lr_retorno.mensagem = "Telefone nao pode ser celular!"
        otherwise
            let lr_retorno.codigo   = 1
            let lr_retorno.mensagem = "Tipo de telefone nao encontrado"
    end case

    let l_xml_response = "<?xml version='1.0' encoding='ISO-8859-1' ?>",
                      "<RESPONSE>",
                        "<SERVICO>INCLUIR_TELEFONE_BASE</SERVICO>",
                        "<RETORNO>",
                           "<NUMERO>", lr_retorno.codigo using "<<<&","</NUMERO>",
                           "<MENSAGEM>", lr_retorno.mensagem clipped,"</MENSAGEM>",
                        "</RETORNO>",
                      "</RESPONSE>"
    return l_xml_response

end function

{
    PSI-2015-05269/IN - NovaUra
}
function wdatn001_obter_qra_socorrista()

    define lr_xml    record
           cgccpfnum like datksrr.cgccpfnum,
           cgccpfdig like datksrr.cgccpfdig
    end record
    define lr_retorno   record
           srrcoddig like datksrr.srrcoddig,
           pstcoddig like dpaksocor.pstcoddig,
           codigo    smallint,
           mensagem  char(100)
    end record

    define l_xml_response char(32000)
    define l_xml_dados    char(30000)
    define l_sql          char(6000)

    initialize lr_xml.* to null
    initialize lr_retorno.* to null
    initialize l_xml_response to null
    initialize l_xml_dados to null
    initialize l_sql to null


    let l_sql = " select rel.srrcoddig,        ",
                "        rel.pstcoddig         ",
                "   from datrsrrpst rel,       ",
                "        datksrr    srr        ",
                "  where srr.cgccpfnum = ?     ",
                "    and srr.cgccpfdig = ?     ",
                "    and srr.srrstt = 1        ",
                "    and srr.srrcoddig = rel.srrcoddig   ",
                "    and vigfnl = (select max(vigfnl)    ",
                "                   from datrsrrpst vgn  ",
                "    where vgn.srrcoddig = rel.srrcoddig)"

    prepare p_wdatn001_002 from l_sql
    declare c_wdatn001_001 cursor for p_wdatn001_002

    let lr_xml.cgccpfnum = figrc011_xpath(m_doc_handle, "/REQUEST/CPF/NUMERO")
    let lr_xml.cgccpfdig = figrc011_xpath(m_doc_handle, "/REQUEST/CPF/DIGITO")

    if lr_xml.cgccpfnum is not null and lr_xml.cgccpfnum <> 0 then


        open c_wdatn001_001 using lr_xml.cgccpfnum
                                 ,lr_xml.cgccpfdig
         foreach c_wdatn001_001 into lr_retorno.srrcoddig,
                                     lr_retorno.pstcoddig
            let l_xml_dados  = l_xml_dados clipped,
                                    "<DADOS>",
                                        "<QRA>", lr_retorno.srrcoddig using "<<<<<<<<<<", "</QRA>",
                                        "<BASE>", lr_retorno.pstcoddig using "<<<<<<<<","</BASE>",
                                    "</DADOS>"
         end foreach
        close c_wdatn001_001
        if lr_retorno.srrcoddig is not null and lr_retorno.srrcoddig <> 0 then
            let lr_retorno.codigo   = 0
            let lr_retorno.mensagem = "QRA foi encontrado!"
        else
            let lr_retorno.codigo   = 1
            let lr_retorno.mensagem = "CPF sem vinculo!"
        end if
    else
        let lr_retorno.codigo   = 1
        let lr_retorno.mensagem = "CPF não informado!"
    end if


    let l_xml_response = "<?xml version='1.0' encoding='ISO-8859-1' ?>",
                      "<RESPONSE>",
                        "<SERVICO>OBTER_QRA_SOCORRISTA</SERVICO>",
                        l_xml_dados clipped,
                        "<RETORNO>",
                           "<NUMERO>", lr_retorno.codigo using "<<<&","</NUMERO>",
                           "<MENSAGEM>", lr_retorno.mensagem clipped,"</MENSAGEM>",
                        "</RETORNO>",
                      "</RESPONSE>"
    return l_xml_response

end function

function wdatn001_bloquear_servico()

 define l_atdsrvnum    like datmservico.atdsrvnum
 define l_atdsrvano    like datmservico.atdsrvano
 define l_c24opemat    like datmservico.c24opemat
 define l_c24opeempcod like datmservico.c24opeempcod
 define l_c24opeusrtip like datmservico.c24opeusrtip
 define l_atdfnlflg    like datmservico.atdfnlflg

 initialize l_atdsrvnum
           ,l_atdsrvano
           ,l_c24opemat
           ,l_c24opeempcod
           ,l_c24opeusrtip
           ,l_atdfnlflg    to null

 let l_atdsrvnum    = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/NUMERO_SERVICO_ATENDIMENTO")
 let l_atdsrvano    = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/ANO_SERVICO_ATENDIMENTO")
 let l_c24opemat    = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/BLOQUEIO_SERVICO/USUARIO_BLOQUEIO/MATRICULA")
 let l_c24opeempcod = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/BLOQUEIO_SERVICO/USUARIO_BLOQUEIO/EMPRESA")
 let l_c24opeusrtip = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/BLOQUEIO_SERVICO/USUARIO_BLOQUEIO/TIPO")

  select atdfnlflg into l_atdfnlflg
    from datmservico
   where atdsrvnum = l_atdsrvnum
     and atdsrvano = l_atdsrvano

    if sqlca.sqlcode <> 0 then
       let mr_xml.coderr =  sqlca.sqlcode
       let mr_xml.msgerr = 'Erro ', sqlca.sqlcode, ' ao bloquear servico: obter finalizacao '
       return
    end if

  if l_atdfnlflg = 'S' then  #Servico Finalizado
     let l_c24opemat = 0
     let l_c24opeempcod = 0
     let l_c24opeusrtip = ''
  end if

   whenever error continue
    update datmservico
       set c24opemat    = l_c24opemat
          ,c24opeempcod = l_c24opeempcod
          ,c24opeusrtip = l_c24opeusrtip
     where atdsrvnum    = l_atdsrvnum
       and atdsrvano    = l_atdsrvano
   whenever error stop

    if sqlca.sqlcode = 0 then
       let mr_xml.flgval = "S"
       let mr_xml.coderr = 0
       let mr_xml.msgerr = "Servico bloqueado com sucesso"
    else
       let mr_xml.coderr =  sqlca.sqlcode
       let mr_xml.msgerr = 'Erro ', sqlca.sqlcode, ' ao bloquear servico em datmservico '
    end if

end function


function wdatn001_desbloquear_servico()

 define l_atdsrvnum    like datmservico.atdsrvnum
 define l_atdsrvano    like datmservico.atdsrvano

 initialize l_atdsrvnum
           ,l_atdsrvano to null

 let l_atdsrvnum    = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/NUMERO_SERVICO_ATENDIMENTO")
 let l_atdsrvano    = figrc011_xpath(m_doc_handle, "/REQUEST/SERVICO_ATUALIZACAO/ANO_SERVICO_ATENDIMENTO")

   whenever error continue
    update datmservico
       set c24opemat    = null
          ,c24opeempcod = null
          ,c24opeusrtip = null
     where atdsrvnum    = l_atdsrvnum
       and atdsrvano    = l_atdsrvano
   whenever error stop

    if sqlca.sqlcode = 0 then
       let mr_xml.flgval = "S"
       let mr_xml.coderr = 0
       let mr_xml.msgerr = "Servico desbloqueado com sucesso"
    else
       let mr_xml.coderr =  sqlca.sqlcode
       let mr_xml.msgerr = 'Erro ', sqlca.sqlcode, ' ao desbloquear servico em datmservico '
    end if

end function

function wdatn001_cliente_premium()

   define l_atdsrvnum    like datmservico.atdsrvnum
   define l_atdsrvano    like datmservico.atdsrvano
   define l_xml_ret      char(500)

   define lr_ret     record
          errocod    smallint,
          succod     like  datrservapol.succod    ,
          ramcod     like  datrservapol.ramcod    ,
          aplnumdig  like  datrservapol.aplnumdig ,
          itmnumdig  like  datrservapol.itmnumdig ,
          edsnumref  like  datrservapol.edsnumref
   end record

   define lr_ret2      record
          perfil       smallint                     ,
          clscod       like abbmclaus.clscod   ,
          dt_cal       date                         ,
          vcl0kmflg    like abbmveic.vcl0kmflg      ,
          imsvlr       like abbmcasco.imsvlr        ,
          ctgtrfcod    like abbmcasco.ctgtrfcod     ,
          clalclcod    like abbmdoc.clalclcod       ,
          dctsgmcod    like abbmapldctsgm.dctsgmcod ,
          clisgmcod    like apamconclisgm.clisgmcod
   end record

   initialize l_atdsrvnum, l_atdsrvano to null
   initialize lr_ret.* to null
   initialize lr_ret2.* to null
   initialize l_xml_ret to null
   initialize g_funapol.* to null

   let l_atdsrvnum    = figrc011_xpath(m_doc_handle, "/REQUEST/NUMERO_SERVICO_ATENDIMENTO")
   let l_atdsrvano    = figrc011_xpath(m_doc_handle, "/REQUEST/ANO_SERVICO_ATENDIMENTO")


   call ctd20g08_servapol_sel(1, l_atdsrvnum, l_atdsrvano)
        returning lr_ret.*

   call cty31g00_recupera_perfil(lr_ret.succod, 
                                 lr_ret.aplnumdig,
                                 lr_ret.itmnumdig) 
        returning lr_ret2.*

   if lr_ret2.clisgmcod is null then
       let lr_ret2.clisgmcod = 0
   end if

   if lr_ret2.dctsgmcod is null then
       let lr_ret2.dctsgmcod = 0
   end if

   let l_xml_ret = "<?xml version='1.0' encoding='ISO-8859-1' ?>",
                   "<RESPONSE>",
                      "<SERVICO>",
                         "<SEGMENTO_CLIENTE>", lr_ret2.clisgmcod using "<<<<<&",
                         "</SEGMENTO_CLIENTE>",
                         "<SEGMENTO_DOCUMENTO>", lr_ret2.dctsgmcod using "<<<<&", 
                         "</SEGMENTO_DOCUMENTO>",
                      "</SERVICO>",
                   "</RESPONSE>"

   return l_xml_ret

end function

#------------------------------------------------------------------------------#
 #MODULOS DESATIVADOS
 function bsgfc962_situacao_pvisa()
 end function
 function bsgfc962_situacao_patrimonial()
 end function
 function bsgfc962_vidaprm_portoprev()
 end function
 function bsgfc962_situacao_saude()
 end function
 function bsgfc962_situacao_vital()
 end function
 function bsgfc962_situacao_auto()
 end function
 function bsgfc962_situacao_re()
 end function
#------------------------------------------------------------------------------#
