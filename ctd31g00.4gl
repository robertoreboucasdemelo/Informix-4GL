#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema..: Porto Socorro                                                   #
# Modulo...: ctd31g00                                                        #
# Objetivo.: Gerenciamento da reserva sistemica de veiculo, tabelas          #
#            DATMRSVVCL e DATMVCLRSVITF                                      #
# Analista.: Fabio Costa                                                     #
# PSI      : 260142 - Integracao Carro Extra                                 #
# Liberacao: 30/03/2011                                                      #
#............................................................................#
# Observacoes                                                                #
#............................................................................#
# Alteracoes                                                                 #
#                                                                            #
#----------------------------------------------------------------------------#
database porto
 globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_ctd31g00_prep smallint

#---------------------------#
function ctd31g00_prepare()
#---------------------------#
  define l_sql  char(1500)

  let l_sql = ' insert into datmrsvvcl( '
            , '        atdsrvnum   , atdsrvano   , rsvlclcod   , loccntcod    '
            , '      , cnfenvcod   , rsvsttcod   , atzdianum   , loccautip    '
            , '      , vclretagncod, vclrethordat, vclretufdcod, vclretcidnom '
            , '      , vcldvlagncod, vcldvlhordat, vcldvlufdcod, vcldvlcidnom '
            , '      , smsenvdddnum, smsenvcelnum, envemades   , vclloccdrtxt '
            , '      , vclcdtsgnindtxt, apvhordat)'
            , ' values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)'
  prepare p_ctd31g00_rsv_ins from l_sql

  let l_sql = ' update datmrsvvcl set rsvsttcod = ?, '
            , '                       atzdianum =  ?, '
            , '                       vcldvlhordat = ?, '
            , '                       vclloccdrtxt = ?  '
            , ' where atdsrvnum = ? '
            , '   and atdsrvano = ? '
  prepare p_ctd31g00_rsv_up from l_sql

  let l_sql = ' update datmrsvvcl set loccntcod = ? '
            , ' where atdsrvnum = ? '
            , '   and atdsrvano = ? '
  prepare p_ctd31g00_ctr_upd from l_sql

  let l_sql = ' select r.atdsrvnum   , r.atdsrvano   , r.rsvlclcod    '
            , '      , r.loccntcod   , r.cnfenvcod   , r.rsvsttcod    '
            , '      , r.atzdianum   , r.loccautip   , r.vclretagncod '
            , '      , r.vclrethordat, r.vclretufdcod, r.vclretcidnom '
            , '      , r.vcldvlagncod, r.vcldvlhordat, r.vcldvlufdcod '
            , '      , r.vcldvlcidnom, r.smsenvdddnum, r.smsenvcelnum '
            , '      , r.envemades   , r.vclloccdrtxt, r.vclcdtsgnindtxt '
            , '      , r.apvhordat   , i.intsttcrides, i.itfsttcod '
            , '      , i.itfgrvhordat '
            , ' from datmrsvvcl r, datmvclrsvitf i'
            , ' where r.atdsrvnum = i.atdsrvnum '
            , '   and r.atdsrvano = i.atdsrvano '
            , '   and i.vclitfseq = (select max(vclitfseq) from datmvclrsvitf b'
            , '                      where b.atdsrvnum = i.atdsrvnum '
            , '                        and b.atdsrvano = i.atdsrvano '
            , '                        and b.itftipcod = ? )' -- tipo interface
            , '   and r.atdsrvnum = ? '
            , '   and r.atdsrvano = ? '
  prepare p_ctd31g00_rsv_sel from l_sql
  declare c_ctd31g00_rsv_sel cursor with hold for p_ctd31g00_rsv_sel

  let l_sql = ' select r.rsvlclcod, r.loccntcod, r.rsvsttcod, r.atzdianum '
            , '      , r.apvhordat   '
            , ' from datmrsvvcl r '
            , ' where r.atdsrvnum = ? '
            , '   and r.atdsrvano = ? '
  prepare p_ctd31g00_stt_sel from l_sql
  declare c_ctd31g00_stt_sel cursor with hold for p_ctd31g00_stt_sel

  let l_sql = ' select m.maides '
            , ' from abbmdoc d, gsakendmai m '
            , ' where d.succod    = ? '
            , '   and d.aplnumdig = ? '
            , '   and d.itmnumdig = ? '
            , '   and d.dctnumseq = ? '
            , '   and d.segnumdig = m.segnumdig '
  prepare p_ctd31g00_mai_sel from l_sql
  declare c_ctd31g00_mai_sel cursor with hold for p_ctd31g00_mai_sel

  let l_sql = ' update datmrsvvcl set rsvsttcod = ?, '
            , '                       vclloccdrtxt = ? '
            , ' where atdsrvnum = ? '
            , '   and atdsrvano = ? '
  prepare p_ctd31g00_alt_rsv from l_sql
  let l_sql = ' select rsvlclcod, loccntcod, rsvsttcod '
            , ' from datmrsvvcl '
            , ' where atdsrvnum = ? '
            , '   and atdsrvano = ? '
  prepare p_ctd31g00_loc_sel from l_sql
  declare c_ctd31g00_loc_sel cursor with hold for p_ctd31g00_loc_sel
  let l_sql = ' select vclrethordat '
            , ' from datmrsvvcl r '
            , ' where r.atdsrvnum = ? '
            , '   and r.atdsrvano = ? '
  prepare p_ctd31g00_stt_dev from l_sql
  declare c_ctd31g00_stt_dev cursor with hold for p_ctd31g00_stt_dev
  let l_sql = ' select itftipcod, vclitfseq '
            , ' from datmvclrsvitf '
            , ' where atdsrvnum = ? '
            , '   and atdsrvano = ? '
            , '   order by vclitfseq desc'
  prepare p_ctd31g00_itf from l_sql
  declare c_ctd31g00_itf cursor with hold for p_ctd31g00_itf
  let l_sql = ' update datmrsvvcl set rsvsttcod = ?, '
            , '                       atzdianum = ?, '
            , '                       loccautip = ?, '
            , '                       vclretagncod = ?, '
            , '                       vclrethordat = ?, '
            , '                       vclretufdcod = ?, '
            , '                       vclretcidnom = ?, '
            , '                       vcldvlagncod = ?, '
            , '                       vcldvlhordat = ?, '
            , '                       vcldvlufdcod = ?, '
            , '                       vcldvlcidnom = ?, '
            , '                       smsenvdddnum = ?, '
            , '                       smsenvcelnum = ?, '
            , '                       vclloccdrtxt = ?,  '
            , '                       vclcdtsgnindtxt = ?  '
            , ' where atdsrvnum = ? '
            , '   and atdsrvano = ? '
  prepare p_ctd31g00_rsv_upd from l_sql
  let l_sql = ' select count(*)        ',
              ' from datmvclrsvitf     ',
              ' where atdsrvnum = ?    ',
              ' and atdsrvano =  ?     ',
              ' and itftipcod = 1      ',
              ' and itfsttcod in (1,2) '
  prepare p_ctd31g00_ree from l_sql
  declare c_ctd31g00_ree cursor with hold for p_ctd31g00_ree
  let m_ctd31g00_prep = true

end function


# Incluir solicitacao de reserva de veiculo com dados de detalhes
#----------------------------------------------------------------
function ctd31g00_ins_reserva(l_reserva)
#----------------------------------------------------------------

  define l_reserva record
         atdsrvnum        like datmrsvvcl.atdsrvnum    ,
         atdsrvano        like datmrsvvcl.atdsrvano    ,
         cnfenvcod        like datmrsvvcl.cnfenvcod    ,
         rsvsttcod        like datmrsvvcl.rsvsttcod    ,
         atzdianum        like datmrsvvcl.atzdianum    ,
         loccautip        like datmrsvvcl.loccautip    ,
         vclretagncod     like datmrsvvcl.vclretagncod ,
         vclrethordat     like datmrsvvcl.vclrethordat ,
         vclretufdcod     like datmrsvvcl.vclretufdcod ,
         vclretcidnom     like datmrsvvcl.vclretcidnom ,
         vcldvlagncod     like datmrsvvcl.vcldvlagncod ,
         vcldvlhordat     like datmrsvvcl.vcldvlhordat ,
         vcldvlufdcod     like datmrsvvcl.vcldvlufdcod ,
         vcldvlcidnom     like datmrsvvcl.vcldvlcidnom ,
         smsenvdddnum     like datmrsvvcl.smsenvdddnum ,
         smsenvcelnum     like datmrsvvcl.smsenvcelnum ,
         envemades        like datmrsvvcl.envemades    ,
         vclloccdrtxt     like datmrsvvcl.vclloccdrtxt ,
         vclcdtsgnindtxt  like datmrsvvcl.vclcdtsgnindtxt,
         succod           like abbmdoc.succod          ,
         aplnumdig        like abbmdoc.aplnumdig       ,
         itmnumdig        like abbmdoc.itmnumdig       ,
         dctnumseq        like abbmdoc.dctnumseq       ,
         ramcod           like datkazlapl.ramcod       ,
         edsnumdig        like datkazlapl.edsnumdig    ,
         empcod           like datmservico.ciaempcod
  end record

  define l_interface record
         itftipcod  like datmvclrsvitf.itftipcod , # codigo do tipo da interface
         itfsttcod  like datmvclrsvitf.itfsttcod   # codigo status interface
  end record

  define l_stt, l_err smallint
  define l_msg     char(80)
  define l_errmsg  char(80)

  initialize l_interface.* to null
  initialize l_stt, l_err, l_msg, l_errmsg to null

  if m_ctd31g00_prep is null or
     m_ctd31g00_prep != true
     then
     call ctd31g00_prepare()
  end if

  # parametros para incluir solicitacao
  let l_interface.itftipcod = 1   # tipo interface, Solicitar reserva
  let l_interface.itfsttcod = 1   # status interface, Solicitada
  let l_reserva.rsvsttcod   = 1   # status reserva, Aguardando envio
  let l_err = 0

  # validacao de parametros
  while true
     if l_reserva.atzdianum is null then
        let l_err = 991  let l_msg = "Numero de diarias nao informado"
        exit while
     end if
     if l_reserva.atdsrvnum is null or l_reserva.atdsrvnum <= 0 or
        l_reserva.atdsrvano is null or l_reserva.atdsrvano <= 0 then
        let l_err = 991  let l_msg = "Numero do servico nao informado"
        exit while
     end if
     if l_reserva.loccautip is null or l_reserva.loccautip <= 0 then
        let l_err = 991  let l_msg = "Tipo de caucao nao informado"
        exit while
     end if
     if l_reserva.vclretufdcod is null then
        let l_err = 991  let l_msg = "UF da reserva nao informada"
        exit while
     end if
     if l_reserva.vclretcidnom is null then
        let l_err = 991  let l_msg = "Cidade da reserva nao informada"
        exit while
     end if
     if l_reserva.vclrethordat is null then
        let l_err = 991  let l_msg = "Data/hora retirada nao informada"
        exit while
     end if
     if l_reserva.vcldvlhordat is null then
        let l_err = 991  let l_msg = "Data/hora devolucao nao informada"
        exit while
     end if
     if l_reserva.vcldvlhordat <= l_reserva.vclrethordat
        then
        let l_err = 992  let l_msg = "Data/hora devolucao menor ou igual a data/hora retirada"
        exit while
     end if
     #if l_reserva.vclrethordat < current
     #   then
     #   let l_err = 993  let l_msg = "Data/hora retirada menor que o horario atual"
     #   exit while
     #end if

     # reenvio de solicitacao de reserva ainda nao implementado, somente fase 2
     call ctd31g00_sel_reserva_itftip(2,  l_reserva.atdsrvnum,
                                      l_reserva.atdsrvano, 1)
          returning l_stt

     if l_stt = 100
        then
        let l_err = 0
     else
        let l_err = 994
        let l_msg = "Reenvio de solicitacao de reserva nao implementado"
     end if

     exit while
  end while

  if l_err != 0
     then
     return l_err, l_msg
  end if

  # obter e-mail do segurado para confirmacao da reserva
  whenever error continue

  if l_reserva.empcod is not null
     then
     case
        when l_reserva.empcod = 1
           if l_reserva.succod    is not null and
              l_reserva.aplnumdig is not null and
              l_reserva.itmnumdig is not null and
              l_reserva.dctnumseq is not null
              then
              open c_ctd31g00_mai_sel using l_reserva.succod    , l_reserva.aplnumdig ,
                                            l_reserva.itmnumdig , l_reserva.dctnumseq
              fetch c_ctd31g00_mai_sel into l_reserva.envemades

              if sqlca.sqlcode != 0 or l_reserva.envemades is null
                 then
                 let l_msg = "Erro na obtencao do e-mail: ", sqlca.sqlcode
              end if
           else
              let l_msg = "E-mail nao identificado, dados insuficientes"
           end if

        when l_reserva.empcod = 35
           call ctd31g00_email_azul(l_reserva.succod   , l_reserva.ramcod   ,
                                    l_reserva.aplnumdig, l_reserva.itmnumdig,
                                    l_reserva.edsnumdig, '' )
                returning l_reserva.envemades, l_msg

        otherwise
           let l_msg = "E-mail outras empresas, nao implementado"
     end case
  else
     let l_msg = "E-mail nao identificado, empresa nao informada"
  end if

  whenever error stop

  begin work

  # insere detalhes da reserva
  whenever error continue
  execute p_ctd31g00_rsv_ins using l_reserva.atdsrvnum    ,
                                   l_reserva.atdsrvano    ,
                                   ''                     ,   # Codigo localizador da reserva
                                   ''                     ,   # Codigo do contrato da locacao
                                   l_reserva.cnfenvcod    ,   # Tipo do envio de confirmacao           1 Mail, 2 SMS
                                   l_reserva.rsvsttcod    ,   # codigo status da reserva               NN
                                   l_reserva.atzdianum    ,   # numero de diarias autorizadas          NN
                                   l_reserva.loccautip    ,   # Tipo de caucao da reserva              NN, 1, 2, 3
                                   l_reserva.vclretagncod ,   # Agencia da retirada do veiculo
                                   l_reserva.vclrethordat ,   # Data hora da retirada do veiculo       NN
                                   l_reserva.vclretufdcod ,   # Codigo UF de retirada do veiculo       NN
                                   l_reserva.vclretcidnom ,   # Nome Cidade de retirada do veiculo     NN
                                   l_reserva.vcldvlagncod ,   # Codigo Agencia da devolucao do veiculo
                                   l_reserva.vcldvlhordat ,   # Data hora da devolucao do veiculo
                                   l_reserva.vcldvlufdcod ,   # Codigo UF de devolucao do veiculo
                                   l_reserva.vcldvlcidnom ,   # Nome Cidade de devolucao do veiculo
                                   l_reserva.smsenvdddnum ,   # DDD para envio de SMS
                                   l_reserva.smsenvcelnum ,   # Numero celular para envio de SMS
                                   l_reserva.envemades    ,   # Email para envio de confirmacao
                                   l_reserva.vclloccdrtxt ,   # Consideracoes importantes (100 caract)
                                   l_reserva.vclcdtsgnindtxt, # Indicacao de segundo condutor
                                   ''                         # Data/hora da aprovacao da reserva
  whenever error stop

  let l_err = sqlca.sqlcode

  # insere solicitacao de interface
  if l_err = 0
     then
     call ctd32g00_ins_interface(l_reserva.atdsrvnum  , l_reserva.atdsrvano  ,
                                 l_interface.itftipcod, l_interface.itfsttcod,
                                 '')
          returning l_stt

     if l_stt = 0
        then
        commit work
     else
        let l_err = l_stt
        rollback work
     end if

  else
     rollback work
  end if

  return l_err, l_msg

end function

#----------------------------------------------------------------
function ctd31g00_sel_reserva_solic(l_param)
#----------------------------------------------------------------

  define l_param record
         nivel_retorno  smallint                  ,
         atdsrvnum      like datmrsvvcl.atdsrvnum ,
         atdsrvano      like datmrsvvcl.atdsrvano
  end record

  define l_reserva record
         atdsrvnum        like datmrsvvcl.atdsrvnum    ,
         atdsrvano        like datmrsvvcl.atdsrvano    ,
         rsvlclcod        like datmrsvvcl.rsvlclcod    ,
         loccntcod        like datmrsvvcl.loccntcod    ,
         cnfenvcod        like datmrsvvcl.cnfenvcod    ,
         rsvsttcod        like datmrsvvcl.rsvsttcod    ,
         atzdianum        like datmrsvvcl.atzdianum    ,
         loccautip        like datmrsvvcl.loccautip    ,
         vclretagncod     like datmrsvvcl.vclretagncod ,
         vclrethordat     like datmrsvvcl.vclrethordat ,
         vclretufdcod     like datmrsvvcl.vclretufdcod ,
         vclretcidnom     like datmrsvvcl.vclretcidnom ,
         vcldvlagncod     like datmrsvvcl.vcldvlagncod ,
         vcldvlhordat     like datmrsvvcl.vcldvlhordat ,
         vcldvlufdcod     like datmrsvvcl.vcldvlufdcod ,
         vcldvlcidnom     like datmrsvvcl.vcldvlcidnom ,
         smsenvdddnum     like datmrsvvcl.smsenvdddnum ,
         smsenvcelnum     like datmrsvvcl.smsenvcelnum ,
         envemades        like datmrsvvcl.envemades    ,
         vclloccdrtxt     like datmrsvvcl.vclloccdrtxt ,
         vclcdtsgnindtxt  like datmrsvvcl.vclcdtsgnindtxt,
         apvhordat        like datmrsvvcl.apvhordat      ,
         intsttcrides     like datmvclrsvitf.intsttcrides,
         itfsttcod        like datmvclrsvitf.itfsttcod ,
         itfgrvhordat     like datmvclrsvitf.itfgrvhordat
  end record

  define l_ret integer, l_msg char(60)

  initialize l_reserva.* to null

  # obter dados da ultima interface de solicitacao, tipo 1
  call ctd31g00_sel_reserva_itftip(1, l_param.atdsrvnum, l_param.atdsrvano, 1)
       returning l_ret, l_msg,
                 l_reserva.atdsrvnum    ,
                 l_reserva.atdsrvano    ,
                 l_reserva.rsvlclcod    ,
                 l_reserva.loccntcod    ,
                 l_reserva.cnfenvcod    ,
                 l_reserva.rsvsttcod    ,
                 l_reserva.atzdianum    ,
                 l_reserva.loccautip    ,
                 l_reserva.vclretagncod ,
                 l_reserva.vclrethordat ,
                 l_reserva.vclretufdcod ,
                 l_reserva.vclretcidnom ,
                 l_reserva.vcldvlagncod ,
                 l_reserva.vcldvlhordat ,
                 l_reserva.vcldvlufdcod ,
                 l_reserva.vcldvlcidnom ,
                 l_reserva.smsenvdddnum ,
                 l_reserva.smsenvcelnum ,
                 l_reserva.envemades    ,
                 l_reserva.vclloccdrtxt ,
                 l_reserva.vclcdtsgnindtxt,
                 l_reserva.apvhordat    ,
                 l_reserva.intsttcrides ,
                 l_reserva.itfsttcod    ,
                 l_reserva.itfgrvhordat

  if l_param.nivel_retorno = 1
     then
     return l_ret, l_msg,
            l_reserva.atdsrvnum    ,
            l_reserva.atdsrvano    ,
            l_reserva.rsvlclcod    ,
            l_reserva.loccntcod    ,
            l_reserva.cnfenvcod    ,
            l_reserva.rsvsttcod    ,
            l_reserva.atzdianum    ,
            l_reserva.loccautip    ,
            l_reserva.vclretagncod ,
            l_reserva.vclrethordat ,
            l_reserva.vclretufdcod ,
            l_reserva.vclretcidnom ,
            l_reserva.vcldvlagncod ,
            l_reserva.vcldvlhordat ,
            l_reserva.vcldvlufdcod ,
            l_reserva.vcldvlcidnom ,
            l_reserva.smsenvdddnum ,
            l_reserva.smsenvcelnum ,
            l_reserva.envemades    ,
            l_reserva.vclloccdrtxt ,
            l_reserva.vclcdtsgnindtxt,
            l_reserva.apvhordat    ,
            l_reserva.intsttcrides ,
            l_reserva.itfsttcod    ,
            l_reserva.itfgrvhordat
  end if

  return l_ret, l_msg

end function

#----------------------------------------------------------------
function ctd31g00_sel_reserva_itftip(l_param)
#----------------------------------------------------------------
# selecionar reserva solicitada para interface com a Localiza

  define l_param record
         nivel_retorno  smallint                  ,
         atdsrvnum      like datmrsvvcl.atdsrvnum ,
         atdsrvano      like datmrsvvcl.atdsrvano ,
         itftipcod      like datmvclrsvitf.itftipcod
  end record

  define l_reserva record
         atdsrvnum        like datmrsvvcl.atdsrvnum    ,
         atdsrvano        like datmrsvvcl.atdsrvano    ,
         rsvlclcod        like datmrsvvcl.rsvlclcod    ,
         loccntcod        like datmrsvvcl.loccntcod    ,
         cnfenvcod        like datmrsvvcl.cnfenvcod    ,
         rsvsttcod        like datmrsvvcl.rsvsttcod    ,
         atzdianum        like datmrsvvcl.atzdianum    ,
         loccautip        like datmrsvvcl.loccautip    ,
         vclretagncod     like datmrsvvcl.vclretagncod ,
         vclrethordat     like datmrsvvcl.vclrethordat ,
         vclretufdcod     like datmrsvvcl.vclretufdcod ,
         vclretcidnom     like datmrsvvcl.vclretcidnom ,
         vcldvlagncod     like datmrsvvcl.vcldvlagncod ,
         vcldvlhordat     like datmrsvvcl.vcldvlhordat ,
         vcldvlufdcod     like datmrsvvcl.vcldvlufdcod ,
         vcldvlcidnom     like datmrsvvcl.vcldvlcidnom ,
         smsenvdddnum     like datmrsvvcl.smsenvdddnum ,
         smsenvcelnum     like datmrsvvcl.smsenvcelnum ,
         envemades        like datmrsvvcl.envemades    ,
         vclloccdrtxt     like datmrsvvcl.vclloccdrtxt ,
         vclcdtsgnindtxt  like datmrsvvcl.vclcdtsgnindtxt,
         apvhordat        like datmrsvvcl.apvhordat      ,
         intsttcrides     like datmvclrsvitf.intsttcrides,
         itfsttcod        like datmvclrsvitf.itfsttcod ,
         itfgrvhordat     like datmvclrsvitf.itfgrvhordat
  end record

  define l_ret integer, l_msg char(60)

  initialize l_reserva.* to null

  let l_ret = 0

  if l_param.nivel_retorno is null or
     l_param.nivel_retorno <= 0
     then
     let l_ret = 999
     let l_msg = 'Erro no envio de parametros'
     return l_ret, l_msg, l_reserva.*
  end if

  if m_ctd31g00_prep is null or
     m_ctd31g00_prep != true
     then
     call ctd31g00_prepare()
  end if

  whenever error continue
  open c_ctd31g00_rsv_sel using l_param.itftipcod, l_param.atdsrvnum,
                                l_param.atdsrvano
  fetch c_ctd31g00_rsv_sel into l_reserva.atdsrvnum    ,
                                l_reserva.atdsrvano    ,
                                l_reserva.rsvlclcod    ,
                                l_reserva.loccntcod    ,
                                l_reserva.cnfenvcod    ,
                                l_reserva.rsvsttcod    ,
                                l_reserva.atzdianum    ,
                                l_reserva.loccautip    ,
                                l_reserva.vclretagncod ,
                                l_reserva.vclrethordat ,
                                l_reserva.vclretufdcod ,
                                l_reserva.vclretcidnom ,
                                l_reserva.vcldvlagncod ,
                                l_reserva.vcldvlhordat ,
                                l_reserva.vcldvlufdcod ,
                                l_reserva.vcldvlcidnom ,
                                l_reserva.smsenvdddnum ,
                                l_reserva.smsenvcelnum ,
                                l_reserva.envemades    ,
                                l_reserva.vclloccdrtxt ,
                                l_reserva.vclcdtsgnindtxt,
                                l_reserva.apvhordat    ,
                                l_reserva.intsttcrides ,
                                l_reserva.itfsttcod    ,
                                l_reserva.itfgrvhordat
  whenever error stop

  let l_ret = sqlca.sqlcode

  close c_ctd31g00_rsv_sel

  if l_param.nivel_retorno = 1
     then
     return l_ret, l_msg,
            l_reserva.atdsrvnum    ,
            l_reserva.atdsrvano    ,
            l_reserva.rsvlclcod    ,
            l_reserva.loccntcod    ,
            l_reserva.cnfenvcod    ,
            l_reserva.rsvsttcod    ,
            l_reserva.atzdianum    ,
            l_reserva.loccautip    ,
            l_reserva.vclretagncod ,
            l_reserva.vclrethordat ,
            l_reserva.vclretufdcod ,
            l_reserva.vclretcidnom ,
            l_reserva.vcldvlagncod ,
            l_reserva.vcldvlhordat ,
            l_reserva.vcldvlufdcod ,
            l_reserva.vcldvlcidnom ,
            l_reserva.smsenvdddnum ,
            l_reserva.smsenvcelnum ,
            l_reserva.envemades    ,
            l_reserva.vclloccdrtxt ,
            l_reserva.vclcdtsgnindtxt,
            l_reserva.apvhordat    ,
            l_reserva.intsttcrides ,
            l_reserva.itfsttcod    ,
            l_reserva.itfgrvhordat
  end if

  if l_param.nivel_retorno = 2
     then
     return l_ret
  end if

end function

#----------------------------------------------------------------
function ctd31g00_email_azul(l_azul)
#----------------------------------------------------------------

  define l_res         integer
       , l_msg         char(80)
       , l_doc_handle  integer
       , l_mail        char(50)

  define l_azul record
         succod        like datrservapol.succod    ,
         ramcod        like datrservapol.ramcod    ,
         aplnumdig     like datrservapol.aplnumdig ,
         itmnumdig     like datkazlapl.itmnumdig   ,
         edsnumdig     like datkazlapl.edsnumdig   ,
         azlaplcod     like datkazlapl.itmnumdig
  end record

  initialize l_res, l_msg, l_doc_handle to null

  call ctd02g01_azlaplcod(l_azul.succod   , l_azul.ramcod,
                          l_azul.aplnumdig, l_azul.itmnumdig, l_azul.edsnumdig)
       returning l_res, l_msg, l_azul.azlaplcod

  if l_res != 1 or l_res is null
     then
     let l_msg = 'Erro na selecao da apolice Azul, suc: ', l_azul.succod
               , '/ ram: ', l_azul.ramcod
               , '/ apl: ', l_azul.aplnumdig
               , '/ itm: ', l_azul.itmnumdig
     return '', l_msg
  end if

  call figrc011_inicio_parse()

  let l_doc_handle = ctd02g00_agrupaXML(l_azul.azlaplcod)

  let l_mail = figrc011_xpath(l_doc_handle, "/APOLICE/SEGURADO/ENDERECO/EMAIL")

  call figrc011_fim_parse()

  return l_mail, ''

end function

# Alterar numero de diarias da reserva
#----------------------------------------------------------------
function ctd31g00_alt_diarias(l_reserva)
#----------------------------------------------------------------

  define l_reserva record
         atdsrvnum  like datmrsvvcl.atdsrvnum,
         atdsrvano  like datmrsvvcl.atdsrvano,
         totdianum  smallint                 ,  # numero de dias da reserva
         autdianum  smallint,                   # numero de diarias autorizadas
         ##vclrethordat char(20), #like datmrsvvcl.vclrethordat
         vcldvlhordat char(20), #like datmrsvvcl.vcldvlhordat
         vclloccdrtxt like datmrsvvcl.vclloccdrtxt
  end record
  define l_vclrethordat like datmrsvvcl.vclrethordat,
         l_vcldvlhordat like datmrsvvcl.vcldvlhordat

  define l_txtalt  char(100)
  define l_sttnew, l_err smallint
  define l_msg     char(80)
  #let  l_vclrethordat= null
  let  l_vcldvlhordat= null

  #let l_vclrethordat = l_reserva.vclrethordat
  let l_vcldvlhordat = l_reserva.vcldvlhordat
  initialize l_txtalt, l_sttnew, l_err, l_msg to null

  if m_ctd31g00_prep is null or
     m_ctd31g00_prep != true
     then
     call ctd31g00_prepare()
  end if

  #  FASE 01 !!
  let l_sttnew = 1  # reserva alterada

  #whenever error continue
  execute p_ctd31g00_rsv_up using l_sttnew,
                                   l_reserva.autdianum,
                                   #l_vclrethordat,
                                   l_vcldvlhordat,
                                   l_reserva.vclloccdrtxt,
                                   l_reserva.atdsrvnum,
                                   l_reserva.atdsrvano
  #whenever error stop

  let l_err = sqlca.sqlcode

   if l_err != 0

      then
      return l_err, l_msg
   end if
   if l_reserva.autdianum > l_reserva.totdianum then
      let l_reserva.totdianum = l_reserva.autdianum
   end if

   let l_txtalt = "ALTERADIARIAS|TOTAL=", l_reserva.totdianum,
                  "|AUTORIZADAS=", l_reserva.autdianum

   call ctd32g00_ins_interface(l_reserva.atdsrvnum, l_reserva.atdsrvano,
                               5, 1, l_txtalt)
        returning l_err

  return l_err, l_msg

end function

#----------------------------------------------------------------
function ctd31g00_ver_solicitacao(l_param)
#----------------------------------------------------------------

  define l_param record
         atdsrvnum   like datmrsvvcl.atdsrvnum ,
         atdsrvano   like datmrsvvcl.atdsrvano
  end record

  define l_reserva record
         rsvlclcod   like datmrsvvcl.rsvlclcod ,
         loccntcod   like datmrsvvcl.loccntcod ,
         rsvsttcod   like datmrsvvcl.rsvsttcod ,
         atzdianum   like datmrsvvcl.atzdianum ,
         apvhordat   like datmrsvvcl.apvhordat
  end record

  define l_dominio record
         erro      smallint  ,
         mensagem  char(100) ,
         cpodes    like iddkdominio.cpodes
  end record

  define l_ret integer, l_msg char(80), l_err smallint

  initialize l_ret, l_err, l_msg to null
  initialize l_reserva.* to null
  initialize l_dominio.* to null

  if m_ctd31g00_prep is null or
     m_ctd31g00_prep != true
     then
     call ctd31g00_prepare()
  end if

  let l_err = 0

  whenever error continue
  open c_ctd31g00_stt_sel using l_param.atdsrvnum, l_param.atdsrvano
  fetch c_ctd31g00_stt_sel into l_reserva.rsvlclcod, l_reserva.loccntcod,
                                l_reserva.rsvsttcod, l_reserva.atzdianum,
                                l_reserva.apvhordat
  whenever error stop

  let l_err = sqlca.sqlcode

  close c_ctd31g00_rsv_sel

  # display 'l_err: ', l_err

  if l_err != 0
     then
     let l_msg = "Reserva online nao localizada, erro: ", l_err
     return l_err, l_msg, l_reserva.rsvlclcod
  end if

  # revisar logica na FASE 2
  if l_reserva.rsvsttcod = 2 or
     ##l_reserva.rsvsttcod = 4 or
     l_reserva.rsvsttcod = 5 or
     l_reserva.rsvsttcod = 7 or
     l_reserva.rsvsttcod = 8 or
     l_reserva.rsvsttcod = 10 or
     l_reserva.rsvsttcod = 11
     then
     return l_err, '', l_reserva.rsvlclcod
  else
     whenever error continue
     call cty11g00_iddkdominio('rsvsttcod', l_reserva.rsvsttcod)
          returning l_dominio.erro, l_dominio.mensagem, l_dominio.cpodes
     whenever error stop

     let l_msg = "Reserva em status ", l_dominio.cpodes clipped, " nao pode ser alterada"

     return 999, l_msg, l_reserva.rsvlclcod
  end if
end function
# Solicitar o cancelamento da reserva
#----------------------------------------------------------------
function ctd31g00_canc_rsv(l_reserva)
#----------------------------------------------------------------
  define l_reserva record
         atdsrvnum  like datmrsvvcl.atdsrvnum,
         atdsrvano  like datmrsvvcl.atdsrvano,
         rsvsttcod  like datmrsvvcl.rsvsttcod,
         vclloccdrtxt like datmrsvvcl.vclloccdrtxt
  end record
  define l_txtalt, l_msg  char(100)
  define l_err smallint
  initialize l_txtalt, l_err, l_msg to null
  if m_ctd31g00_prep is null or
     m_ctd31g00_prep != true
     then
     call ctd31g00_prepare()
  end if
  #whenever error continue
  execute p_ctd31g00_alt_rsv using l_reserva.rsvsttcod,
                                   l_reserva.vclloccdrtxt,
                                   l_reserva.atdsrvnum,
                                   l_reserva.atdsrvano
  #whenever error stop
  let l_err = sqlca.sqlcode
   if l_err != 0 then
      let l_msg = 'Erro ', l_err, ' em p_ctd31g00_alt_rsv'
      return l_err, l_msg
   end if
   let l_txtalt = "CANCELAR RESERVA|"
   call ctd32g00_ins_interface(l_reserva.atdsrvnum, l_reserva.atdsrvano,
                               4, 1, l_txtalt)
        returning l_err
  return l_err, l_msg
end function
#----------------------------------------------------------------
function ctd31g00_ver_reserva(l_param)
#----------------------------------------------------------------
  define l_param record
         nivel_ret   smallint,
         atdsrvnum   like datmrsvvcl.atdsrvnum ,
         atdsrvano   like datmrsvvcl.atdsrvano
  end record
  define l_reserva record
         erro        integer,
         rsvlclcod   like datmrsvvcl.rsvlclcod ,
         loccntcod   like datmrsvvcl.loccntcod ,
         rsvsttcod   like datmrsvvcl.rsvsttcod
  end record
  initialize l_reserva.* to null
  if m_ctd31g00_prep is null or
     m_ctd31g00_prep != true
     then
     call ctd31g00_prepare()
  end if

  #whenever error continue
  open c_ctd31g00_loc_sel using l_param.atdsrvnum, l_param.atdsrvano
  fetch c_ctd31g00_loc_sel into l_reserva.rsvlclcod, l_reserva.loccntcod,
                                l_reserva.rsvsttcod
  if sqlca.sqlcode = notfound then
     let l_reserva.erro = 1
  else
     let l_reserva.erro = 0
  end if
  close c_ctd31g00_loc_sel
  #whenever error stop
  if l_param.nivel_ret = 1 then
     return l_reserva.rsvlclcod, l_reserva.rsvsttcod
  end if
  if l_param.nivel_ret = 2 then
     return l_reserva.erro, l_reserva.rsvsttcod, l_reserva.loccntcod
  end if
end function
# Solicitar o reenvio da reserva
#----------------------------------------------------------------
function ctd31g00_reenvio(l_reserva)
#----------------------------------------------------------------
  define l_reserva record
         atdsrvnum  like datmrsvvcl.atdsrvnum,
         atdsrvano  like datmrsvvcl.atdsrvano,
         rsvsttcod  like datmrsvvcl.rsvsttcod,
         vclloccdrtxt like datmrsvvcl.vclloccdrtxt
  end record
  define l_txtalt, l_msg  char(100)
  define l_itftipcod, l_err smallint
  initialize l_txtalt, l_itftipcod, l_err, l_msg to null
  if m_ctd31g00_prep is null or
     m_ctd31g00_prep != true
     then
     call ctd31g00_prepare()
  end if
  #whenever error continue
  execute p_ctd31g00_alt_rsv using l_reserva.rsvsttcod,
                                   l_reserva.vclloccdrtxt,
                                   l_reserva.atdsrvnum,
                                   l_reserva.atdsrvano
  #whenever error stop
  let l_err = sqlca.sqlcode
   if l_err != 0 then
      let l_msg = 'Erro ', l_err, ' em p_ctd31g00_alt_rsv'
      return l_err, l_msg
   end if
   let l_txtalt = "REENVIO DA RESERVA|"
   let l_itftipcod = 0
   open c_ctd31g00_itf using l_reserva.atdsrvnum, l_reserva.atdsrvano
   fetch c_ctd31g00_itf into l_itftipcod
   close c_ctd31g00_itf
   call ctd32g00_ins_interface(l_reserva.atdsrvnum, l_reserva.atdsrvano,
                               l_itftipcod, 1, l_txtalt)
        returning l_err
  return l_err, l_msg
end function
# Cancelar a prorrogacao
#----------------------------------------------------------------
function ctd31g00_canc_prorrog(l_reserva)
#----------------------------------------------------------------
  define l_reserva record
         atdsrvnum  like datmrsvvcl.atdsrvnum,
         atdsrvano  like datmrsvvcl.atdsrvano,
         totdianum  smallint                 ,  # numero de dias da reserva
         autdianum  smallint,                   # numero de diarias autorizadas
         vclloccdrtxt like datmrsvvcl.vclloccdrtxt
  end record
  define l_vclrethordat like datmrsvvcl.vclrethordat,
         l_vcldvlhordat like datmrsvvcl.vcldvlhordat
  define l_txtalt  char(100)
  define l_sttnew, l_err smallint
  define l_msg     char(80)
  #let  l_vclrethordat= null
  let  l_vcldvlhordat= null
  initialize l_txtalt, l_sttnew, l_err, l_msg to null
  if m_ctd31g00_prep is null or
     m_ctd31g00_prep != true
     then
     call ctd31g00_prepare()
  end if
  open c_ctd31g00_stt_dev using l_reserva.atdsrvnum,
                                l_reserva.atdsrvano
  fetch c_ctd31g00_stt_dev into l_vclrethordat
  close c_ctd31g00_stt_dev
  ##let l_vclrethordat = l_vclrethordat - l_reserva.autdianum units day
  let l_vcldvlhordat = l_vclrethordat + l_reserva.autdianum units day
  #  FASE 01 !!
  let l_sttnew = 1  # reserva alterada
  #whenever error continue
  execute p_ctd31g00_rsv_up using l_sttnew,
                                   l_reserva.autdianum,
                                   ##l_vclrethordat,
                                   l_vcldvlhordat,
                                   l_reserva.vclloccdrtxt,
                                   l_reserva.atdsrvnum,
                                   l_reserva.atdsrvano
  #whenever error stop
  let l_err = sqlca.sqlcode
   if l_err != 0
      then
      return l_err, l_msg
   end if
   if l_reserva.autdianum > l_reserva.totdianum then
      let l_reserva.totdianum = l_reserva.autdianum
   end if
   let l_txtalt = "ALTERADIARIAS|TOTAL=", l_reserva.totdianum,
                  "|AUTORIZADAS=", l_reserva.autdianum
   call ctd32g00_ins_interface(l_reserva.atdsrvnum, l_reserva.atdsrvano,
                               5, 1, l_txtalt)
        returning l_err
  return l_err, l_msg
end function
# Alterar solicitacao de reserva de veiculo com dados de detalhes
#----------------------------------------------------------------
function ctd31g00_upd_reserva(l_reserva)
#----------------------------------------------------------------
  define l_reserva record
         atdsrvnum        like datmrsvvcl.atdsrvnum    ,
         atdsrvano        like datmrsvvcl.atdsrvano    ,
         rsvsttcod        like datmrsvvcl.rsvsttcod    ,
         atzdianum        like datmrsvvcl.atzdianum    ,
         loccautip        like datmrsvvcl.loccautip    ,
         vclretagncod     like datmrsvvcl.vclretagncod ,
         vclrethordat     like datmrsvvcl.vclrethordat ,
         vclretufdcod     like datmrsvvcl.vclretufdcod ,
         vclretcidnom     like datmrsvvcl.vclretcidnom ,
         vcldvlagncod     like datmrsvvcl.vcldvlagncod ,
         vcldvlhordat     like datmrsvvcl.vcldvlhordat ,
         vcldvlufdcod     like datmrsvvcl.vcldvlufdcod ,
         vcldvlcidnom     like datmrsvvcl.vcldvlcidnom ,
         smsenvdddnum     like datmrsvvcl.smsenvdddnum ,
         smsenvcelnum     like datmrsvvcl.smsenvcelnum ,
         vclloccdrtxt     like datmrsvvcl.vclloccdrtxt ,
         vclcdtsgnindtxt  like datmrsvvcl.vclcdtsgnindtxt
  end record
  define l_interface record
         itftipcod  like datmvclrsvitf.itftipcod , # codigo do tipo da interface
         itfsttcod  like datmvclrsvitf.itfsttcod   # codigo status interface
  end record
  define l_stt, l_err smallint
  define l_msg     char(80)
  define l_errmsg  char(80)
  initialize l_interface.* to null
  initialize l_stt, l_err, l_msg, l_errmsg to null
  if m_ctd31g00_prep is null or
     m_ctd31g00_prep != true
     then
     call ctd31g00_prepare()
  end if
  # parametros para incluir solicitacao
  let l_interface.itftipcod = 3   # tipo interface, Alterar reserva
  let l_interface.itfsttcod = 1   # status interface, Solicitada
  let l_reserva.rsvsttcod   = 1   # status reserva, Aguardando envio
  let l_err = 0
  # validacao de parametros
  while true
     if l_reserva.atzdianum is null then
        let l_err = 991  let l_msg = "Numero de diarias nao informado"
        exit while
     end if
     if l_reserva.atdsrvnum is null or l_reserva.atdsrvnum <= 0 or
        l_reserva.atdsrvano is null or l_reserva.atdsrvano <= 0 then
        let l_err = 991  let l_msg = "Numero do servico nao informado"
        exit while
     end if
     if l_reserva.loccautip is null or l_reserva.loccautip <= 0 then
        let l_err = 991  let l_msg = "Tipo de caucao nao informado"
        exit while
     end if
     if l_reserva.vclretufdcod is null then
        let l_err = 991  let l_msg = "UF da reserva nao informada"
        exit while
     end if
     if l_reserva.vclretcidnom is null then
        let l_err = 991  let l_msg = "Cidade da reserva nao informada"
        exit while
     end if
     if l_reserva.vclrethordat is null then
        let l_err = 991  let l_msg = "Data/hora retirada nao informada"
        exit while
     end if
     if l_reserva.vcldvlhordat is null then
        let l_err = 991  let l_msg = "Data/hora devolucao nao informada"
        exit while
     end if
     if l_reserva.vcldvlhordat <= l_reserva.vclrethordat
        then
        let l_err = 992  let l_msg = "Data/hora devolucao menor ou igual a data/hora retirada"
        exit while
     end if
     if l_reserva.vclrethordat < current
        then
        let l_err = 993  let l_msg = "Data/hora retirada menor que o horario atual"
        exit while
     end if
     exit while
  end while
  if l_err != 0
     then
     return l_err, l_msg
  end if
  whenever error continue
  begin work
  # insere detalhes da reserva
  whenever error continue
  execute p_ctd31g00_rsv_upd using
                                   l_reserva.rsvsttcod    ,
                                   l_reserva.atzdianum    ,   # numero de diarias autorizadas          NN
                                   l_reserva.loccautip    ,   # Tipo de caucao da reserva              NN, 1, 2, 3
                                   l_reserva.vclretagncod ,   # Agencia da retirada do veiculo
                                   l_reserva.vclrethordat ,   # Data hora da retirada do veiculo       NN
                                   l_reserva.vclretufdcod ,   # Codigo UF de retirada do veiculo       NN
                                   l_reserva.vclretcidnom ,   # Nome Cidade de retirada do veiculo     NN
                                   l_reserva.vcldvlagncod ,   # Codigo Agencia da devolucao do veiculo
                                   l_reserva.vcldvlhordat ,   # Data hora da devolucao do veiculo
                                   l_reserva.vcldvlufdcod ,   # Codigo UF de devolucao do veiculo
                                   l_reserva.vcldvlcidnom ,   # Nome Cidade de devolucao do veiculo
                                   l_reserva.smsenvdddnum ,   # DDD para envio de SMS
                                   l_reserva.smsenvcelnum ,   # Numero celular para envio de SMS
                                   l_reserva.vclloccdrtxt ,   # Consideracoes importantes (100 caract)
                                   l_reserva.vclcdtsgnindtxt, # Indicacao de segundo condutor
                                   l_reserva.atdsrvnum    ,
                                   l_reserva.atdsrvano
  whenever error stop
  let l_err = sqlca.sqlcode
  # insere solicitacao de interface
  if l_err = 0
     then
     call ctd32g00_ins_interface(l_reserva.atdsrvnum  , l_reserva.atdsrvano  ,
                                 l_interface.itftipcod, l_interface.itfsttcod,
                                 '')
          returning l_stt
     if l_stt = 0
        then
        commit work
     else
        let l_err = l_stt
        rollback work
     end if
  else
     rollback work
  end if
  return l_err, l_msg
end function
#===================================================
function ctd31g00_verifica_reenvio(lr_param)
#===================================================
define lr_param record
    atdsrvnum like datmservico.atdsrvnum,
    atdsrvano like datmservico.atdsrvano
end record
define lr_retorno record
  cont    smallint,
  reenvia smallint
end record
initialize lr_retorno.* to null
 if m_ctd31g00_prep is null or
     m_ctd31g00_prep != true
     then
     call ctd31g00_prepare()
  end if
 whenever error continue
 open c_ctd31g00_ree using lr_param.atdsrvnum,
                           lr_param.atdsrvano
 fetch c_ctd31g00_ree into lr_retorno.cont
 whenever error stop
 if sqlca.sqlcode <> 0 then
    error "Erro ao Buscar Dados da Interface da Reserva!"
 end if
 if lr_retorno.cont > 0 then
    let lr_retorno.reenvia = false
 else
 	  let lr_retorno.reenvia = true
 end if
 return lr_retorno.reenvia
end function
