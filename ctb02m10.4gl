#############################################################################
# Nome de Modulo: CTB02m10                                         Wagner   #
#                                                                           #
# Consulta dos itens da ordem de pagamento (carro-extra)           Out/2000 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#############################################################################

database porto

define d_ctb02m10  record
   socopgnum       like dbsmopg.socopgnum,
   socopgsitcod    like dbsmopg.socopgsitcod,
   socopgsitdes    char(30)
end record

#--------------------------------------------------------------------
function ctb02m10(param)
#--------------------------------------------------------------------
  define param       record
     socopgnum       like dbsmopgitm.socopgnum,
     avialgmtv       like datmavisrent.avialgmtv,
     slcemp          like datmavisrent.slcemp,
     slcsuccod       like datmavisrent.slcsuccod,
     slccctcod       like datmavisrent.slccctcod
  end record

  define a_ctb02m10   array[2000] of record
     nfsnum           like dbsmopgitm.nfsnum,
     atdsrvorg        like datmservico.atdsrvorg,
     atdsrvnum        like dbsmopgitm.atdsrvnum,
     atdsrvano        like dbsmopgitm.atdsrvano,
     qtd_saldo        decimal (6,0),
     qtd_solic        decimal (6,0),
     c24utidiaqtd     like dbsmopgitm.c24utidiaqtd,
     c24pagdiaqtd     like dbsmopgitm.c24pagdiaqtd,
     socopgtotvlr     like dbsmopgitm.socopgitmvlr,
     socopgitmcst     like dbsmopgcst.socopgitmcst,
     socopgitmvlr     like dbsmopgitm.socopgitmvlr,
     socopgitmnum     like dbsmopgitm.socopgitmnum
  end record

  define ws           record
     comando          char(500),
     saldo            smallint                     ,
     clscod           like abbmclaus.clscod        ,
     aviprvent        like datmavisrent.aviprvent  ,
     aviprvent_rat    like datmavisrent.aviprvent  ,
     avialgmtv        like datmavisrent.avialgmtv  ,
     aviprodiaqtd     like datmprorrog.aviprodiaqtd,
     slcemp           like datmavisrent.slcemp,
     slcsuccod        like datmavisrent.slcsuccod,
     slccctcod        like datmavisrent.slccctcod,
     aviprodiaqtd_tot like datmprorrog.aviprodiaqtd,
     c24utidiaqtd_pro like dbsmopgitm.c24utidiaqtd,
     rsrincdat        like dbsmopgitm.rsrincdat,
     rsrfnldat        like dbsmopgitm.rsrfnldat
  end record

  define arr_aux      smallint
  define scr_aux      smallint
  define ws_flgsub    smallint

  initialize a_ctb02m10    to null
  initialize d_ctb02m10.*  to null
  initialize ws.*          to null

  let ws.comando = "select atdsrvorg     ",
                   "  from datmservico   ",
                   " where atdsrvnum = ? ",
                   "   and atdsrvano = ? "
  prepare sel_srvorg    from   ws.comando
  declare c_ctb02m10srv cursor for sel_srvorg

  let ws.comando = "select atdetpcod    ",
                   "  from datmsrvacp   ",
                   " where atdsrvnum = ?",
                   "   and atdsrvano = ?",
                   "   and atdsrvseq = (select max(atdsrvseq)",
                                       "  from datmsrvacp    ",
                                       " where atdsrvnum = ? ",
                                       "   and atdsrvano = ?)"
  prepare sel_datmsrvacp from ws.comando
  declare c_datmsrvacp cursor for sel_datmsrvacp


  open window w_ctb02m10 at 06,02 with form "ctb02m10"
       attribute(form line first, comment line last - 1)

  let arr_aux = 1
  let d_ctb02m10.socopgnum = param.socopgnum

  # MONTA DADOS DA ORDEM DE PAGAMENTO
  #----------------------------------
  select socopgnum
    from dbsmopg
   where socopgnum = param.socopgnum

  if sqlca.sqlcode <> 0    then
     error " Erro (",sqlca.sqlcode,") na leitura da ordem de pagamento!"
     return
  end if

  # MONTA ITENS DA ORDEM DE PAGAMENTO
  #----------------------------------
  message " Aguarde, pesquisando..."  attribute(reverse)

  declare c_ctb02m10  cursor for
    select dbsmopgitm.nfsnum      , dbsmopgitm.atdsrvnum   ,
           dbsmopgitm.atdsrvano   , dbsmopgitm.c24utidiaqtd,
           dbsmopgitm.c24pagdiaqtd, dbsmopgitm.socopgitmvlr,
           dbsmopgitm.socopgitmnum, datmavisrent.avialgmtv ,
           datmavisrent.slcemp    , datmavisrent.slcsuccod ,
           datmavisrent.slccctcod , datmavisrent.aviprvent ,
           dbsmopgitm.rsrincdat   , dbsmopgitm.rsrfnldat   , 
           sum(dbsmopgcst.socopgitmcst)
      from dbsmopgitm, datmavisrent, outer dbsmopgcst
     where dbsmopgitm.socopgnum      = param.socopgnum
       and datmavisrent.atdsrvnum    = dbsmopgitm.atdsrvnum
       and datmavisrent.atdsrvano    = dbsmopgitm.atdsrvano
       and dbsmopgcst.socopgnum      = dbsmopgitm.socopgnum
       and dbsmopgcst.socopgitmnum   = dbsmopgitm.socopgitmnum
     group by dbsmopgitm.nfsnum      , dbsmopgitm.atdsrvnum   ,
              dbsmopgitm.atdsrvano   , dbsmopgitm.c24utidiaqtd,
              dbsmopgitm.c24pagdiaqtd, dbsmopgitm.socopgitmvlr,
              dbsmopgitm.socopgitmnum, datmavisrent.avialgmtv ,
              datmavisrent.slcemp    , datmavisrent.slcsuccod ,
              datmavisrent.slccctcod , datmavisrent.aviprvent ,
              dbsmopgitm.rsrincdat   , dbsmopgitm.rsrfnldat 
     order by dbsmopgitm.socopgitmnum

  foreach c_ctb02m10 into a_ctb02m10[arr_aux].nfsnum,
                          a_ctb02m10[arr_aux].atdsrvnum,
                          a_ctb02m10[arr_aux].atdsrvano,
                          a_ctb02m10[arr_aux].c24utidiaqtd,
                          a_ctb02m10[arr_aux].c24pagdiaqtd,
                          a_ctb02m10[arr_aux].socopgitmvlr,
                          a_ctb02m10[arr_aux].socopgitmnum,
                          ws.avialgmtv,
                          ws.slcemp,
                          ws.slcsuccod,
                          ws.slccctcod,
                          ws.aviprvent,
                          ws.rsrincdat,
                          ws.rsrfnldat,
                          a_ctb02m10[arr_aux].socopgitmcst
                           

     if param.avialgmtv is not null     and
        param.avialgmtv <> ws.avialgmtv then
        continue foreach
     end if

     if param.slccctcod is not null       then
        if param.slcemp    = ws.slcemp    and
           param.slcsuccod = ws.slcsuccod and
           param.slccctcod = ws.slccctcod then
        else
           continue foreach
        end if
     end if

     open  c_ctb02m10srv using a_ctb02m10[arr_aux].atdsrvnum,
                               a_ctb02m10[arr_aux].atdsrvano
     fetch c_ctb02m10srv into  a_ctb02m10[arr_aux].atdsrvorg
     close c_ctb02m10srv

     if a_ctb02m10[arr_aux].socopgitmcst is null then
        let a_ctb02m10[arr_aux].socopgitmcst = 0
     end if

     let ws.aviprodiaqtd_tot = 0

     let ws.aviprvent_rat = ws.aviprvent 
     if param.avialgmtv is null  then     
        let ws.aviprvent_rat = a_ctb02m10[arr_aux].c24pagdiaqtd 
     else
        if ws.avialgmtv = 4         and      
           ws.rsrincdat is not null then  
           let ws.aviprvent_rat = a_ctb02m10[arr_aux].c24pagdiaqtd 
        end if
     end if
     
        #-------------------------------------------------
        # Verifica se tem prorrogacao por Centro de custo
        #-------------------------------------------------
        select sum(aviprodiaqtd)
          into ws.aviprodiaqtd_tot
          from datmprorrog
          where atdsrvnum = a_ctb02m10[arr_aux].atdsrvnum
            and atdsrvano = a_ctb02m10[arr_aux].atdsrvano
            and cctcod    is not null
            and aviprostt = "A"

        if ws.aviprodiaqtd_tot is null then
           let ws.aviprodiaqtd_tot = 0
        end if

        if ws.aviprodiaqtd_tot <> 0 then
           #-------------------------------------------------
           # Tem reserva com prorrogacao por Centro de custo
           #-------------------------------------------------
           let a_ctb02m10[arr_aux].socopgitmvlr =
                                     (a_ctb02m10[arr_aux].socopgitmvlr /
                                      a_ctb02m10[arr_aux].c24pagdiaqtd *
                                      ws.aviprvent_rat)
           let a_ctb02m10[arr_aux].socopgitmcst =
                                     (a_ctb02m10[arr_aux].socopgitmcst /
                                      a_ctb02m10[arr_aux].c24pagdiaqtd *
                                      ws.aviprvent_rat)

           let a_ctb02m10[arr_aux].c24utidiaqtd =
                                      ws.aviprvent_rat
           let a_ctb02m10[arr_aux].c24pagdiaqtd =
                                      ws.aviprvent_rat

        else
           #-------------------------------------------------
           # Verifica se tem prorrogacao SEM Centro de custo
           #-------------------------------------------------
           select sum(aviprodiaqtd)
             into ws.aviprodiaqtd_tot
             from datmprorrog
             where atdsrvnum = a_ctb02m10[arr_aux].atdsrvnum
               and atdsrvano = a_ctb02m10[arr_aux].atdsrvano
               and aviprostt = "A"

           if ws.aviprodiaqtd_tot is null then
              let ws.aviprodiaqtd_tot = 0
           end if
        end if
#WWW end if

     let a_ctb02m10[arr_aux].socopgtotvlr = a_ctb02m10[arr_aux].socopgitmvlr +
                                     (a_ctb02m10[arr_aux].socopgitmcst * (-1))

     if ws.avialgmtv = 4         and      
        ws.rsrincdat is not null then  
        select sum(aviprodiaqtd)
          into a_ctb02m10[arr_aux].qtd_solic 
          from datmprorrog
         where atdsrvnum = a_ctb02m10[arr_aux].atdsrvnum
           and atdsrvano = a_ctb02m10[arr_aux].atdsrvano
           and aviprostt = "A"
           and vclretdat between ws.rsrincdat and ws.rsrfnldat
     else 
        let a_ctb02m10[arr_aux].qtd_solic = ws.aviprvent + ws.aviprodiaqtd_tot
     end if

     let arr_aux = arr_aux + 1
     if arr_aux > 2000   then
        error " Limite excedido! Ordem de pagamento com mais de 2000 itens!"
        exit foreach
     end if

  end foreach

  message ""
  call set_count(arr_aux-1)
  call cabec_ctb02m10()
  let  ws_flgsub = 0
  message " (F17)Abandona"

  let int_flag = false

  display  array a_ctb02m10 to s_ctb02m10.*

     on key (interrupt,control-c)
        exit display

  end display

 let int_flag = false
 close window w_ctb02m10

end function  ###  ctb02m10

#--------------------------------------------------------------------
function cabec_ctb02m10()
#--------------------------------------------------------------------

 select socopgsitcod
   into d_ctb02m10.socopgsitcod
   from dbsmopg
  where socopgnum = d_ctb02m10.socopgnum

 if sqlca.sqlcode  <>  0   then
    error " Erro (",sqlca.sqlcode,") na leitura da O.P. durante montagem do cabecalho!"
    return
 end if

 select cpodes
   into d_ctb02m10.socopgsitdes
   from iddkdominio
  where cponom = "socopgsitcod"   and
        cpocod = d_ctb02m10.socopgsitcod

 if sqlca.sqlcode  <>  0   then
    error " Erro (",sqlca.sqlcode,") na leitura da situacao!"
    return
 end if

 display by name d_ctb02m10.socopgnum
 display by name d_ctb02m10.socopgsitcod
 display by name d_ctb02m10.socopgsitdes

end function  ###  cabec_ctb02m10

