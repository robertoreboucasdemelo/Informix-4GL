#---------------------------------------------------------------------------#
# Nome do Modulo: CTN16C01                                         Marcelo  #
#                                                                  Gilberto #
# Mostra todos as solicitacoes/confirmacoes de reserva             Mar/1998 #
#---------------------------------------------------------------------------#
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 14/10/1998               Gilberto     Incluir mensagem de espera durante  #
#                                       calculo do saldo de diarias.        #
#---------------------------------------------------------------------------#
# 20/11/1998  ** ERRO **   Gilberto     Retirar a tabela DATKAVISVEIC do    #
#                                       'join' para evitar 'sequential scan'#
#---------------------------------------------------------------------------#
# 11/02/1999  PSI 7669-4   Wagner       Data do calculo para saldo de dias  #
#                                       foi alterado de (data atendimento)  #
#                                       para (data do sinistro).            #
#---------------------------------------------------------------------------#
# 03/05/1999  PSI 7547-7   Wagner       Adaptacao leitura tabela de etapas  #
#                                       para verificacao do servico.        #
#---------------------------------------------------------------------------#
# 27/06/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.   #
#---------------------------------------------------------------------------#
# 16/02/2001  PSI 10631-1  Wagner       Acesso tambem as tabelas da OP para #
#                                       adaptacao pagamento carro-extra.    #
#---------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa           PSI.168920     Resolucao 86         #
#---------------------------------------------------------------------------#
# 16/03/2004  Teresinha Silva           OSF 33367      Inlusao do motivo 6  #
# --------------------------------------------------------------------------#
database porto

#------------------------------------------------------------
 function ctn16c01(k_ctn16c01)
#------------------------------------------------------------

 define k_ctn16c01    record
    succod       like abbmclaus.succod      ,
    aplnumdig    like abbmclaus.aplnumdig   ,
    itmnumdig    like abbmclaus.itmnumdig   ,
    clcdat       date                       ,
    viginc       like abbmclaus.viginc      ,
    vigfnl       like abbmclaus.vigfnl
 end record

 define a_ctn16c01 array[20] of record
    atdsrvorg    like datmservico.atdsrvorg ,
    atdsrvnum    like datmservico.atdsrvnum ,
    atdsrvano    like datmservico.atdsrvano ,
    lcvnom       char (12)                  ,
    atddat       like datmservico.atddat    ,
    aviretdat    like datmavisrent.aviretdat,
    aviprvent    like datmavisrent.aviprvent,
    vclalgdat    like datmavisrent.vclalgdat,
    pagdiaqtd    like dblmpagto.c24pagdiaqtd
 end record

 define ws       record
    lcvcod       like datklocadora.lcvcod     ,
    avivclcod    like datkavisveic.avivclcod  ,
    avivclgrp    like datkavisveic.avivclgrp  ,
    c24utidiaqtd like dblmpagto.c24utidiaqtd  ,
    aviprodiaqtd like datmprorrog.aviprodiaqtd,
    avialgmtv    like datmavisrent.avialgmtv  ,
    avioccdat    like datmavisrent.avioccdat  ,
    atdetpcod    like datmsrvacp.atdetpcod
 end record

 define arr_aux  smallint

 define sql      char (300)

#------------------------------------------------------------
# Inicializacao das variaveis
#------------------------------------------------------------

 initialize  a_ctn16c01   to null
 initialize  ws.*         to null

 let sql = "select c24pagdiaqtd,",
           "       c24utidiaqtd ",
           "  from dblmpagto    ",
           " where atdsrvnum = ?  and",
           "       atdsrvano = ?     "
 prepare sel_algpgt from sql
 declare c_algpgt cursor for sel_algpgt

 let sql = "select aviprodiaqtd        ",
           "  from datmprorrog         ",
           " where atdsrvnum  =  ?  and",
           "       atdsrvano  =  ?  and",
           "       aviprostt  = 'A'    "
 prepare sel_prorrog from sql
 declare c_prorrog cursor for sel_prorrog

 let sql = "select lcvnom      ",
           "  from datklocadora",
           " where lcvcod = ?  "
 prepare sel_locadora from sql
 declare c_locadora cursor for sel_locadora

 let sql = "select avivclgrp     ",
           "  from datkavisveic  ",
           " where lcvcod    = ? ",
           "   and avivclcod = ? "
 prepare sel_veiculo  from sql
 declare c_veiculo  cursor for sel_veiculo

 let sql = "select atdetpcod    ",
           "  from datmsrvacp   ",
           " where atdsrvnum = ?",
           "   and atdsrvano = ?",
           "   and atdsrvseq = (select max(atdsrvseq)",
                               "  from datmsrvacp    ",
                               " where atdsrvnum = ? ",
                               "   and atdsrvano = ?)"
 prepare sel_datmsrvacp from sql
 declare c_datmsrvacp cursor for sel_datmsrvacp


 open window  w_ctn16c01 at 08,02  with form  "ctn16c01"
      attribute(form line first)

 let arr_aux = 1

 message " Aguarde, pesquisando..."  attribute (reverse)

 declare c_reservas   cursor for
    select datmservico.atdsrvnum , datmservico.atdsrvano ,
           datmservico.atddat    , datmavisrent.aviretdat,
           datmavisrent.vclalgdat, datmavisrent.aviprvent,
           datmavisrent.avialgmtv, datmavisrent.lcvcod   ,
           datmavisrent.avivclcod, datmavisrent.avioccdat,
           datmservico.atdsrvorg
      from datrservapol, datmservico, datmavisrent
     where datrservapol.succod     = k_ctn16c01.succod        and
           datrservapol.ramcod     in (31,531)                and
           datrservapol.aplnumdig  = k_ctn16c01.aplnumdig     and
           datrservapol.itmnumdig  = k_ctn16c01.itmnumdig     and

           datmservico.atdsrvnum   = datrservapol.atdsrvnum   and
           datmservico.atdsrvano   = datrservapol.atdsrvano   and
           datmservico.atdsrvorg   =  8                       and
           datmservico.atdfnlflg   = "S"                      and

           datmavisrent.atdsrvnum  = datmservico.atdsrvnum    and
           datmavisrent.atdsrvano  = datmservico.atdsrvano

 foreach c_reservas  into   a_ctn16c01[arr_aux].atdsrvnum,
                            a_ctn16c01[arr_aux].atdsrvano,
                            a_ctn16c01[arr_aux].atddat   ,
                            a_ctn16c01[arr_aux].aviretdat,
                            a_ctn16c01[arr_aux].vclalgdat,
                            a_ctn16c01[arr_aux].aviprvent,
                            ws.avialgmtv                 ,
                            ws.lcvcod                    ,
                            ws.avivclcod                 ,
                            ws.avioccdat                 ,
                            a_ctn16c01[arr_aux].atdsrvorg

    #------------------------------------------------------------
    # Verifica etapa dos servicos
    #------------------------------------------------------------
    open  c_datmsrvacp using a_ctn16c01[arr_aux].atdsrvnum,
                             a_ctn16c01[arr_aux].atdsrvano,
                             a_ctn16c01[arr_aux].atdsrvnum,
                             a_ctn16c01[arr_aux].atdsrvano
    fetch c_datmsrvacp into  ws.atdetpcod
    close c_datmsrvacp

    if ws.atdetpcod <> 4      then   # somente servicos etapa concluida
       continue foreach
    end if

    if ws.avialgmtv = 2  or    ### Reserva por motivo SOCORRO
       ws.avialgmtv = 3  or    ### Reserva por motivo BENEF.OFICINA
       ws.avialgmtv = 6  or    ### TERC.SEGPORTO  -- OSF 33367
       ws.avialgmtv = 9  then  ### Reserva por motivo OUTROS USOS
       continue foreach
    end if

    if k_ctn16c01.viginc is not null  then  ### Reserva antes contratacao clausula
       if ws.avioccdat < k_ctn16c01.viginc  then
          continue foreach
       end if
    end if

    if k_ctn16c01.vigfnl is not null  then  ### Reserva depois contratacao clausula
       if ws.avioccdat > k_ctn16c01.vigfnl  then
          continue foreach
       end if
    end if

    if ws.avioccdat > k_ctn16c01.clcdat  then   ### Reserva apos data de calculo
       continue foreach
    end if

    initialize ws.avivclgrp  to null

    open  c_veiculo using ws.lcvcod   ,
                          ws.avivclcod
    fetch c_veiculo into  ws.avivclgrp
    close c_veiculo

    if ws.avivclgrp <> "A"  then ### Veiculo NAO basico
       continue foreach
    end if

#------------------------------------------------------------
# Nome da locadora
#------------------------------------------------------------

    open  c_locadora using ws.lcvcod
    fetch c_locadora into  a_ctn16c01[arr_aux].lcvnom
    close c_locadora

    call c24geral_tratbrc(a_ctn16c01[arr_aux].lcvnom)
                returning a_ctn16c01[arr_aux].lcvnom

#------------------------------------------------------------
# Prorrogacoes da reserva
#------------------------------------------------------------

    let ws.aviprodiaqtd = 0

    open    c_prorrog using a_ctn16c01[arr_aux].atdsrvnum,
                            a_ctn16c01[arr_aux].atdsrvano
    foreach c_prorrog into  ws.aviprodiaqtd
       let a_ctn16c01[arr_aux].aviprvent = a_ctn16c01[arr_aux].aviprvent + ws.aviprodiaqtd
    end foreach

#------------------------------------------------------------
# Verificacao das confirmacoes
#------------------------------------------------------------

    open  c_algpgt  using  a_ctn16c01[arr_aux].atdsrvnum,
                           a_ctn16c01[arr_aux].atdsrvano
    fetch c_algpgt  into   a_ctn16c01[arr_aux].pagdiaqtd,
                           ws.c24utidiaqtd

    if sqlca.sqlcode = notfound  then
       select c24pagdiaqtd, c24utidiaqtd
         into a_ctn16c01[arr_aux].pagdiaqtd, ws.c24utidiaqtd
         from dbsmopgitm, dbsmopg
        where dbsmopgitm.atdsrvnum = a_ctn16c01[arr_aux].atdsrvnum
          and dbsmopgitm.atdsrvano = a_ctn16c01[arr_aux].atdsrvano
          and dbsmopg.socopgnum    = dbsmopgitm.socopgnum
          and dbsmopg.socopgsitcod in (6,7)

       if sqlca.sqlcode = notfound  then
          initialize a_ctn16c01[arr_aux].vclalgdat  to null
          initialize a_ctn16c01[arr_aux].pagdiaqtd  to null
       else
          let a_ctn16c01[arr_aux].aviprvent = ws.c24utidiaqtd
       end if
    else
       let a_ctn16c01[arr_aux].aviprvent = ws.c24utidiaqtd
    end if

    close c_algpgt

    let arr_aux = arr_aux + 1

    if arr_aux > 20  then
       error " Limite excedido. Apolice com mais de 20 reservas!"
       exit foreach
    end if
 end foreach

 message " (F17)Abandona"
 if arr_aux  =  1   then
    error " Nao existem solicitacoes de reserva para esta apolice!"
 end if

 call set_count(arr_aux - 1)

 display array  a_ctn16c01 to s_ctn16c01.*
    on key (interrupt)
       exit display
 end display

 let int_flag = false
 close window w_ctn16c01

end function  ###  ctn16c01
